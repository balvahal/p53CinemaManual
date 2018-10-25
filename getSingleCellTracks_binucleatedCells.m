function [singleCellTracks_mean, singleCellTracks_median, singleCellTracks_foci, singleCellTracks_area, singleCellTracks_solidity, singleCellTracks_focus_row, singleCellTracks_focus_col] = getSingleCellTracks_binucleatedCells(database, rawdatapath, group, position, measurementChannels, segmentationChannel, centroids, ff_offset, ff_gain)
trackedCells = centroids.getTrackedCellIds;
numTracks = length(trackedCells);
numTimepoints = length(centroids.singleCells);

singleCellTracks_mean = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));
singleCellTracks_median = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));
singleCellTracks_foci = repmat({-ones(numTracks, numTimepoints)},1,length(measurementChannels));

singleCellTracks_area = -ones(numTracks, numTimepoints);
singleCellTracks_solidity = -ones(numTracks, numTimepoints);
singleCellTracks_focus_row = -ones(numTracks, numTimepoints);
singleCellTracks_focus_col = -ones(numTracks, numTimepoints);

[~, segmentationChannelIndex] = ismember(segmentationChannel, measurementChannels);

info = imfinfo(fullfile(rawdatapath, getDatabaseFile2(database, group, measurementChannels{1}, position, 1)));
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
    end

    scalingFactor = 1;
    currentCentroids(:,1) = max(1,min(floor(currentCentroids(:,1) * scalingFactor), info.Height));
    currentCentroids(:,2) = max(1, min(floor(currentCentroids(:,2) * scalingFactor), info.Width));
        
    % Per centroid segmentation and thresholding, from Jacob's script
    siz = 111;
    for j=1:size(currentCentroids,1)
        currentCell = validCells(j);
        
        segmentationImage = IntensityImages_blurred{segmentationChannelIndex};
        
        [zoomImage, newCentroid1, ~]=GetBlock(segmentationImage,currentCentroids(j,:),currentCentroids(j,:),siz);
        zoomImage=(imfilter(zoomImage,fspecial('gaussian',5,2),'replicate'));
        binaryMask=autoscale(zoomImage);
        
        g3 = GetBlock(binaryMask,newCentroid1,newCentroid1,11);
        
        the=median(g3(:));
        the=the-1*mad(g3(:));
        
        binaryMask=binaryMask>(min(median(binaryMask(:)),graythresh(binaryMask))+the)/2;
        binaryMask=imfill(binaryMask,'holes');
        binaryMask=bwlabel(binaryMask); binaryMask=(binaryMask==binaryMask(floor(siz/2),floor(siz/2)));
        try
            localMaxima = imregionalmax(zoomImage) .* binaryMask;
            [local_row, local_col] = ind2sub(size(localMaxima), find(localMaxima > 0));
            local_centroids = [local_row, local_col];
            local_values = zoomImage(localMaxima > 0);
            
            [local_values, ordering] = sort(local_values, 'descend');
            local_centroids = local_centroids(ordering,:);
            
            distances = pdist2(local_centroids, newCentroid1);
            configuration = sum(distances,2);
            selected = find(configuration <= 5, 1, 'first');
            
            if(~isempty(selected))
                singleCellTracks_foci{1}(validCells(j),i) = local_values(selected);
                singleCellTracks_focus_col(validCells(j),i) = 1;
            else
                singleCellTracks_foci{1}(validCells(j),i) = segmentationImage(currentCentroids(j,1), currentCentroids(j,2));
                singleCellTracks_focus_col(validCells(j),i) = -1;
            end
            g3 = GetBlock(zoomImage,newCentroid1,newCentroid1,21);
            g3 = sort(g3(:),'descend');
            singleCellTracks_foci{1}(validCells(j),i) = mean(g3(1:min(9,length(pixelIntensities))));
        catch e
            a = 1;
        end
        nuclearMask = binaryMask;
        cytoplasmicMask = imdilate(binaryMask,strel('disk',3)) .* (~imdilate(binaryMask,strel('disk',1)));
        
        for w=1:length(measurementChannels)
            [subImage, newCentroid1]=GetBlock(IntensityImages_blurred{w},currentCentroids(j,:),currentCentroids(j,:),siz);
            subImage=subImage.*binaryMask;
            [subImage_small, ~]=GetBlock(subImage,newCentroid1,newCentroid1,21);
            pixelIntensities=sort(subImage(:),'descend');
            %singleCellTracks_mean{w}(currentCell,i) = mean(pixelIntensities(pixelIntensities > 0));
            
            singleCellTracks_mean{w}(currentCell,i) = mean(subImage(subImage_small > 0));
            %singleCellTracks_mean{w}(currentCell,i) = IntensityImages_blurred{w}(currentCentroids(currentCell,1),currentCentroids(currentCell,2));

            singleCellTracks_median{w}(currentCell,i) = median(pixelIntensities(pixelIntensities > 0));
            %singleCellTracks_median{w}(j,i) = mean(pixelIntensities(1:min(9,length(pixelIntensities))));
            
            if(w ~= segmentationChannelIndex)
                singleCellTracks_foci{w}(currentCell,i) = mean(pixelIntensities(1:min(9,length(pixelIntensities))));
                %singleCellTracks_foci{w}(currentCell,i) = IntensityImages_blurred{w}(currentCentroids(currentCell,1),currentCentroids(currentCell,2));
                
                %             subImage=GetBlock(IntensityImages_blurred{w},currentCentroids(j,1),currentCentroids(j,2),siz);
                %             subImage=subImage.*(cytoplasmicMask & subImage > 100);
                %             pixelIntensities=sort(subImage(:),'descend');
                %             singleCellTracks_median{w}(currentCell,i) = mean(pixelIntensities(pixelIntensities > 0)) ./ singleCellTracks_mean{w}(currentCell,i);
            end
        end
        singleCellTracks_area(currentCell,i) = sum(binaryMask(:));
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
            end
            singleCellTracks_area(repeatedIndexes,i) = max(singleCellTracks_area(repeatedIndexes,i));
        end
    end
end
fprintf('\n');
end

function [tim, newCentroid1, newCentroid2]=GetBlock(im,centroid1,centroid2,siz)
    hd=(siz-1)/2;
    locX = sort([centroid1(1), centroid2(1)]);
    locY = sort([centroid1(2), centroid2(2)]);
    boundX = [max(1,locX(1)-hd),min(size(im,1),locX(2)+hd)];
    boundY = [max(1,locY(1)-hd),min(locY(2)+hd,size(im,2))];
    tim=im(boundX(1):boundX(2),boundY(1):boundY(2));
    newCentroid1 = centroid1 - [boundX(1), boundY(1)] + 1;
    newCentroid2 = centroid2 - [boundX(1), boundY(1)] + 1;
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