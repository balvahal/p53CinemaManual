function results = getSingleCellTracks_localSegmentation_enhancedThresholding(database, rawdatapath, group, position, measurementChannels, segmentationChannel, centroids, ff_offset, ff_gain)
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
info = imfinfo(fullfile(rawdatapath, database.filename{1}));
info = info(1);
uniqueTimepoints = unique(database.timepoint);

progress = 0;
for t=1:1:length(uniqueTimepoints)
    i= uniqueTimepoints(t);
    if(i/length(uniqueTimepoints) * 100 > progress)
        fprintf('%d ', progress);
        progress = progress + 10;
    end
        
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
        measurementFile = getDatabaseFile2(database, group, measurementChannels{j}, position, i);
        if(isempty(measurementFile))
            continue;
        end
        currentInfo = imfinfo(fullfile(rawdatapath, measurementFile));
        if(length(currentInfo) > 1)
            IM = TiffStack(fullfile(rawdatapath, measurementFile));
            IntensityImages{j} = double(IM.maxProjection);
        else
            IntensityImages{j} = double(imread(fullfile(rawdatapath, measurementFile)));
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
        
    % Per centroid segmentation and thresholding, from Jacob's script
    siz = 111;
    for j=1:size(currentCentroids,1)
        currentCell = validCells(j);
        
        segmentationImage = IntensityImages{segmentationChannelIndex};
        
        binaryMask=GetBlock(segmentationImage,currentCentroids(j,1),currentCentroids(j,2),siz);
        
        %binaryMask=log(binaryMask);
        binaryMask=(imfilter(binaryMask,fspecial('gaussian',5,2),'replicate'));
        binaryMask(binaryMask >= quantile(binaryMask(:), 0.95)) = NaN;
        binaryMask=autoscale(binaryMask);
        
%         g3=binaryMask(max(floor(siz/2)-5, 1):min(floor(siz/2)+5, size(binaryMask,1)),max(floor(siz/2)-5, 1):min(floor(siz/2)+5, size(binaryMask,2)));
%         the=median(g3(:));
%         the=the-1*mad(g3(:));
%         binaryMask=binaryMask>(min(median(binaryMask(:)),graythresh(binaryMask))+the)/2;

        binaryMask = im2bw(binaryMask, graythresh(binaryMask));
        
        binaryMask=imfill(binaryMask,'holes');     
        binaryMask=bwlabel(binaryMask); binaryMask=(binaryMask==binaryMask(floor(siz/2),floor(siz/2)));
        %binaryMask = imdilate(binaryMask,strel('disk',3));
        
        distanceMask = bwdist(~binaryMask);
        distanceMask = distanceMask(:);
        
        nuclearMask = binaryMask;
        cytoplasmicMask = imdilate(binaryMask,strel('disk',3)) .* (~imdilate(binaryMask,strel('disk',1)));
        
        for w=1:length(measurementChannels)
            subImage=GetBlock(IntensityImages_blurred{w},currentCentroids(j,1),currentCentroids(j,2),siz);
            subImage=subImage.*binaryMask;
            [pixelIntensities, ordering]=sort(subImage(:),'descend');
            distanceMask_sorted = distanceMask(ordering);
            
            try
            singleCellTracks_mean{w}(currentCell,i) = mean(pixelIntensities(pixelIntensities > 0));
            singleCellTracks_dilated{w}(currentCell,i) = IntensityImages_blurred{w}(currentCentroids(j,1),currentCentroids(j,2));
            singleCellTracks_integrated{w}(currentCell,i) = sum(pixelIntensities(pixelIntensities > 0));
            singleCellTracks_median{w}(currentCell,i) = median(pixelIntensities(pixelIntensities > 0));
            singleCellTracks_foci{w}(currentCell,i) = mean(pixelIntensities(1:min(9,length(pixelIntensities))));
           
            singleCellTracks_distance{w}(currentCell,i) = mean(distanceMask_sorted(1:min(9,length(pixelIntensities))));
            
            subImage=GetBlock(IntensityImages_blurred{w},currentCentroids(j,1),currentCentroids(j,2),siz);
            subImage=subImage.*(cytoplasmicMask & subImage > 100);
            pixelIntensities=sort(subImage(:),'descend');
            singleCellTracks_ratio{w}(currentCell,i) = mean(pixelIntensities(pixelIntensities > 0)) ./ singleCellTracks_mean{w}(currentCell,i);
            catch e
                a = 1;
            end
        end
        singleCellTracks_area(currentCell,i) = sum(binaryMask(:));
        singleCellTracks_radius(currentCell,i) = max(distanceMask);
        
        nuclearMask = imclearborder(nuclearMask);
        if(sum(nuclearMask(:)) == 0)
            singleCellTracks_solidity(currentCell,i) = -1;
        else
            props = regionprops(binaryMask, 'Solidity');
            singleCellTracks_solidity(currentCell,i) = props.Solidity;
        end
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