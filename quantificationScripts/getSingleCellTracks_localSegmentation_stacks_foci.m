function [results, segmentationImages] = getSingleCellTracks_localSegmentation_stacks_foci(database, rawdatapath, group, position, measurementChannels, segmentationChannel, centroids, ff_offset, ff_gain, varargin)
if(nargin > 9)
    segmentationFile = varargin{1};
else
    segmentationFile = [];
end
trackedCells = centroids.getTrackedCellIds;
numTracks = length(trackedCells);
numTimepoints = length(centroids.singleCells);

singleCellTracks_mean = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));
singleCellTracks_median = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));
singleCellTracks_foci = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));
singleCellTracks_integrated = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));
singleCellTracks_dilated = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));
singleCellTracks_variance = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));
singleCellTracks_ratio = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));
singleCellTracks_distance = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));

singleCellTracks_area = -ones(numTracks, numTimepoints);
singleCellTracks_solidity = -ones(numTracks, numTimepoints);
singleCellTracks_radius = -ones(numTracks, numTimepoints);

[~, segmentationChannelIndex] = ismember(segmentationChannel, measurementChannels);

%info = imfinfo(fullfile(rawdatapath, getDatabaseFile2(database, group, measurementChannels{1}, position, 1)));
subDatabase = database(strcmp(database.channel_name, segmentationChannel),:);
info = imfinfo(fullfile(rawdatapath, subDatabase.filename{1}));
uniqueTimepoints = 1:length(info);
info = info(1);

segmentationImages = zeros(info.Height, info.Width, length(info));

progress = 0;
for t=1:1:length(uniqueTimepoints)
    i= uniqueTimepoints(t);
    if(i/length(uniqueTimepoints) * 100 > progress)
        fprintf('%d ', progress);
        progress = progress + 10;
    end
    
    %i = 38;
    
    % Get current centroids
    [currentCentroids, validCells] = centroids.getCentroids(i);
    [~, validCells] = ismember(validCells, trackedCells);
    
%     fprintf('%d\n', i);
%    continue; 
    
    if(isempty(validCells))
        continue;
    end
    
    IntensityImages = repmat({NaN * ones(info.Width, info.Height)}, 1, length(measurementChannels));
    IntensityImages_blurred = repmat({NaN * ones(info.Width, info.Height)}, 1, length(measurementChannels));
    
    % Read images for every channel
    for j=1:length(measurementChannels)
        measurementFile = database.filename{strcmp(database.group_label,group) & strcmp(database.channel_name, measurementChannels{j}) & database.position_number == position};
        if(isempty(measurementFile))
            continue;
        end
        try
            IntensityImages{j} = double(imread(fullfile(rawdatapath, measurementFile),i));
        catch e
            continue;
        end
        if(~isempty(ff_gain{j}))
            IntensityImages{j} = flatfield_correctImage(IntensityImages{j}, ff_offset{j}, ff_gain{j});
        end
        
        % IntensityImage = medfilt2(IntensityImage, [2,2]);
        IntensityImages{j} = imbackground(IntensityImages{j}, 10, 100);
        
        % [y,x] = hist(log(IntensityImages{j}(IntensityImages{j} > 0)), 1000);
        % x_background = x(find(y == max(y), 1, 'first'));
        % IntensityImages{j} = max(0, IntensityImages{j} - exp(x_background));
        IntensityImages_blurred{j} = imfilter(IntensityImages{j}, fspecial('gaussian', 5, 1));
        %IntensityImages_blurred{j} = imfilter(IntensityImages{j}, fspecial('gaussian', 20, 5));
    end

    scalingFactor = 1;
    currentCentroids(:,1) = max(1,min(floor(currentCentroids(:,1) * scalingFactor), info.Height));
    currentCentroids(:,2) = max(1, min(floor(currentCentroids(:,2) * scalingFactor), info.Width));
    
    currentCentroidIndexes = sub2ind(size(IntensityImages{segmentationChannelIndex}), currentCentroids(:,1), currentCentroids(:,2));
    
    % Per centroid segmentation and thresholding, from Jacob's script
    siz = 51;
    
    zoomMask = NaN * ones(size(IntensityImages{segmentationChannelIndex}));
    boundingBox(1,1) = max(1, min(currentCentroids(:,1)) - siz);
    boundingBox(1,2) = min(size(zoomMask,1), max(currentCentroids(:,1)) + siz);
    boundingBox(2,1) = max(1, min(currentCentroids(:,2)) - siz);
    boundingBox(2,2) = min(size(zoomMask,2), max(currentCentroids(:,2)) + siz);
    zoomMask(boundingBox(1,1):boundingBox(1,2), boundingBox(2,1):boundingBox(2,2)) = 1;
    
    segmentationImage = log(IntensityImages{segmentationChannelIndex} + 1);
    segmentationImage = IntensityImages{segmentationChannelIndex};
    centroidImage = zeros(size(segmentationImage));
    centroidImage(currentCentroidIndexes) = 1;
    
    binaryMask = segmentationImage;
    centroidMask = centroidImage;
    
    blurredSegmentationImage = segmentationImage;
    %blurredSegmentationImage = medfilt2(blurredSegmentationImage, [10,10]);
    blurredSegmentationImage = imfilter(blurredSegmentationImage, fspecial('gaussian',7,4));
    
    if(isempty(segmentationFile))
        binaryMask = segmentationImage;
        binaryMask=(imfilter(binaryMask,fspecial('gaussian',20,2),'replicate'));
        binaryMask = imnormalize(binaryMask);
        binaryMask = binaryMask .* zoomMask;
        minimumThreshold = min(binaryMask(currentCentroidIndexes));
        
        subImage = binaryMask(boundingBox(1,1):boundingBox(1,2), boundingBox(2,1):boundingBox(2,2));
        threshold = SEGMENTATION_TriangleMethod(subImage, 0.999);
        binaryMask = binaryMask > threshold * 1.5;
        
        %binaryMask = im2bw(binaryMask, min(minimumThreshold, graythresh(binaryMask)));
        
        binaryMask=imfill(binaryMask,'holes');
        binaryMask=imerode(binaryMask,strel('disk', 2));
        binaryMask=imopen(binaryMask,strel('disk', 10));
        binaryMask=imdilate(binaryMask,strel('disk', 2));

        binaryMask = bwlabel(binaryMask);
        binaryMask = ismember(binaryMask, binaryMask(currentCentroidIndexes)) & binaryMask > 0;
        
        distanceMask = bwdist(~binaryMask);
        refinedMaxima = imregionalmax(distanceMask .* (distanceMask > 10));
        refinedMaxima = bwmorph(refinedMaxima, 'shrink', 'Inf');
        
        MaximaSuppressionSize = 10;
        MaximaMask = getnhood(strel('disk', MaximaSuppressionSize));
        refinedMaxima(distanceMask < ordfilt2(distanceMask,sum(MaximaMask(:)),MaximaMask)) = 0;

        [refined_col, refined_row] = ind2sub(size(refinedMaxima), find(refinedMaxima));
        if(length(refined_col) >= size(currentCentroids,1))
            distanceMatrix = zeros(size(currentCentroids,1), length(refined_col));
            for k=1:size(currentCentroids,1)
                distance = sqrt((refined_col - currentCentroids(k,1)).^2 + (refined_row - currentCentroids(k,2)).^2);
                %newCentroids(k) = find(distance == min(distance), 1, 'first');
                distanceMatrix(k,:) = distance;
            end
            
            newCentroids = assignmentoptimal(distanceMatrix);
            refinedCentroidMask = zeros(size(refinedMaxima));
            refinedCentroidMask(sub2ind(size(refinedMaxima), refined_col(newCentroids), refined_row(newCentroids))) = 1;
        else
            refinedCentroidMask = centroidMask;
        end
        %watershedImage = imimposemin(-blurredSegmentationImage, refinedCentroidMask);
        watershedImage = imimposemin(-distanceMask, refinedCentroidMask);
        watershedImage = (watershed(watershedImage) > 0) .* double(binaryMask);
        watershedImage = bwlabel(watershedImage);
    else
        binaryMask = imread(segmentationFile, i);
        distanceMask = bwdist(~binaryMask);
        watershedImage = binaryMask;
    end
    
    segmentationImages(:,:,t) = watershedImage;
    
    for j=1:size(currentCentroids,1)
        currentCell = validCells(j);
        
        if(watershedImage(currentCentroids(j,1), currentCentroids(j,2)) == 0)
            continue;
        end
        
        currentBinaryMask = watershedImage == watershedImage(currentCentroids(j,1), currentCentroids(j,2));
        
        currentDistanceMask = distanceMask .* currentBinaryMask; currentDistanceMask = currentDistanceMask(:);
        currentCentroidMask = imdilate(centroidMask, strel('disk', 10)) .* currentBinaryMask;
        
        nuclearMask = currentBinaryMask;
        cytoplasmicMask = imdilate(currentBinaryMask,strel('disk',3)) .* (~imdilate(currentBinaryMask,strel('disk',1)));
        
        for w=1:length(measurementChannels)
            subImage=IntensityImages_blurred{w};
            subImage1=subImage;
            subImage1(currentBinaryMask == 0) = NaN;
            %subImage1=subImage.*currentBinaryMask;
            subImage2=subImage.*currentCentroidMask;
            [pixelIntensities1, ordering]=sort(subImage1(:),'descend');
            [pixelIntensities2, ~]=sort(subImage2(:),'descend');
            distanceMask_sorted = currentDistanceMask(ordering);
            
            try
                foci_intensity = nanmean(pixelIntensities1(1:min(9,length(pixelIntensities1))));
                singleCellTracks_foci{w}(currentCell,i) = foci_intensity;
                singleCellTracks_mean{w}(currentCell,i) = nanmean(pixelIntensities1(pixelIntensities1 > 0));
                singleCellTracks_dilated{w}(currentCell,i) = IntensityImages_blurred{w}(currentCentroids(j,1),currentCentroids(j,2));
                singleCellTracks_integrated{w}(currentCell,i) = nansum(pixelIntensities1(pixelIntensities1 > 0));
                singleCellTracks_median{w}(currentCell,i) = nanmedian(pixelIntensities1(pixelIntensities1 > 0 & pixelIntensities1 < foci_intensity));
                
                singleCellTracks_distance{w}(currentCell,i) = mean(distanceMask_sorted(1:min(9,length(pixelIntensities1))));
                
                subImage=GetBlock(IntensityImages_blurred{w},currentCentroids(j,1),currentCentroids(j,2),siz);
                subImage=subImage.*(cytoplasmicMask & subImage > 100);
                pixelIntensities=sort(subImage(:),'descend');
                singleCellTracks_ratio{w}(currentCell,i) = mean(pixelIntensities(pixelIntensities > 0)) ./ singleCellTracks_mean{w}(currentCell,i);
            catch e
                a = 1;
            end
        end
    end
    singleCellTracks_area(currentCell,i) = sum(binaryMask(:));
    singleCellTracks_radius(currentCell,i) = max(currentDistanceMask);
    
    nuclearMask = imclearborder(nuclearMask);
    if(sum(nuclearMask(:)) == 0)
        singleCellTracks_solidity(currentCell,i) = -1;
    else
        props = regionprops(nuclearMask, 'Solidity');
        singleCellTracks_solidity(currentCell,i) = props.Solidity;
    end
    
    % Repeated values (divisions, for instance)
    currentCentroids = sub2ind(size(IntensityImages{1}), currentCentroids(:,1), currentCentroids(:,2));
    if(length(currentCentroids) > 1)
        centroidFrequency = tabulate(currentCentroids);
        repeatedValues = centroidFrequency(centroidFrequency(:,2) > 1,1);
        for j=1:length(repeatedValues)
            repeatedIndexes = validCells(currentCentroids == repeatedValues(j));
            for w=1:length(measurementChannels)
                singleCellTracks_foci{w}(repeatedIndexes,i) = max(singleCellTracks_foci{w}(repeatedIndexes,i));
                singleCellTracks_mean{w}(repeatedIndexes,i) = max(singleCellTracks_mean{w}(repeatedIndexes,i));
                singleCellTracks_median{w}(repeatedIndexes,i) = max(singleCellTracks_median{w}(repeatedIndexes,i));
                singleCellTracks_distance{w}(repeatedIndexes,i) = max(singleCellTracks_distance{w}(repeatedIndexes,i));
                singleCellTracks_integrated{w}(repeatedIndexes,i) = max(singleCellTracks_integrated{w}(repeatedIndexes,i));
                singleCellTracks_dilated{w}(repeatedIndexes,i) = max(singleCellTracks_dilated{w}(repeatedIndexes,i));
                singleCellTracks_ratio{w}(repeatedIndexes,i) = max(singleCellTracks_ratio{w}(repeatedIndexes,i));
                singleCellTracks_variance{w}(repeatedIndexes,i) = max(singleCellTracks_variance{w}(repeatedIndexes,i));
            end
            singleCellTracks_area(repeatedIndexes,i) = max(singleCellTracks_area(repeatedIndexes,i));
            singleCellTracks_solidity(repeatedIndexes,i) = max(singleCellTracks_solidity(repeatedIndexes,i));
            singleCellTracks_radius(repeatedIndexes,i) = max(singleCellTracks_radius(repeatedIndexes,i));
        end
    end
end
fprintf('\n');

results.singleCellTracks_mean = singleCellTracks_mean;
results.singleCellTracks_median = singleCellTracks_median;
results.singleCellTracks_foci = singleCellTracks_foci;
results.singleCellTracks_integrated = singleCellTracks_integrated;
results.singleCellTracks_dilated = singleCellTracks_dilated;
results.singleCellTracks_variance = singleCellTracks_variance;
results.singleCellTracks_ratio = singleCellTracks_ratio;
results.singleCellTracks_area = singleCellTracks_area;
results.singleCellTracks_solidity = singleCellTracks_solidity;
results.singleCellTracks_distance = singleCellTracks_distance;
results.singleCellTracks_radius = singleCellTracks_radius;
end

function [tim]=GetBlock(im,locX,locY,siz)

    hd=(siz-1)/2;
    tim=im(max(1,locX-hd):min(size(im,1),locX+hd),max(1,locY-hd):min(locY+hd,size(im,2)));

end

function [ino, fmi, fma]=autoscale(in,f,m)

in=double(in);
a=find(~isnan(in));
s=sort(in(a));
if nargin==1; 
    f=0.01;
    fmi=s(floor(f*length(s))+1);
    fma=s(floor((1-f)*length(s))+1);
elseif nargin==2; 
    fmi=s(max(1,floor(f*length(s))));
    fma=s(max(1,floor((1-f)*length(s))));
elseif nargin==3
    fmi=f; fma=m;
end

ino=(in-fmi)/(fma-fmi);
ino=max(0,ino);
ino=min(1,ino);
end

function val = meanSortedPixels(x)
    s = sort(x,'descend');
    val = mean(s(1:min(9,length(s))));
end