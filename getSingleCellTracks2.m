function singleCellTracks = getSingleCellTracks2(rawdatapath, database, group, position, channel, centroids, ff_offset, ff_gain)
    trackedCells = centroids.getTrackedCellIds;
    numTracks = length(trackedCells);
    numTimepoints = length(centroids.singleCells);
        
    singleCellTracks = -ones(numTracks, numTimepoints);
    progress = 0;
    for i=1:numTimepoints
        if(i/numTimepoints * 100 > progress)
            fprintf('%d ', progress);
            progress = progress + 10;
        end
        filename = getDatabaseFile2(database, group, channel, position, i);
        [currentCentroids, validCells] = centroids.getCentroids(i);
        [~, validCells] = ismember(validCells, trackedCells);
        if(isempty(filename) || isempty(validCells))
            continue;
        end
        YFP = double(imread(fullfile(rawdatapath, filename)));
        YFP_background = imbackground(YFP, 10, 100);
        %YFP_background = imfilter(YFP_background, fspecial('gaussian', 30, 4));
        scalingFactor = 1;
        currentCentroids(:,1) = min(ceil(currentCentroids(:,1) * scalingFactor), size(YFP,1));
        currentCentroids(:,2) = min(ceil(currentCentroids(:,2) * scalingFactor), size(YFP,2));
        
        currentCentroids = sub2ind(size(YFP), currentCentroids(:,1), currentCentroids(:,2));
        diskMask = getnhood(strel('disk',12));
        diskMask = diskMask / sum(diskMask(:));
        diskFilteredImage = imfilter(YFP_background, diskMask, 'replicate');
        
%         binaryMask = zeros(size(YFP_background));
%         binaryMask(currentCentroids) = 1;
%         binaryMask = imdilate(bwlabel(binaryMask), strel('disk', 10));
%         props = regionprops(binaryMask, YFP_background, 'PixelValues');
%         measurements = zeros(length(props),1);
%         for j=1:length(measurements)
%             if(~isempty(props(j).PixelValues))
%                 currentValues = props(j).PixelValues;
%                 q = quantile(currentValues, [0.5, 0.95]);
%                 measurements(j) = mean(currentValues(currentValues >= q(1) & currentValues <= q(2)));
%             end
%         end
        
        singleCellTracks(validCells,i) = diskFilteredImage(currentCentroids);
%         singleCellTracks(binaryMask(currentCentroids),i) = measurements(binaryMask(currentCentroids));
    end
    fprintf('%d\n', progress);
end