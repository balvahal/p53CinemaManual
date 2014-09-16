function singleCellTracks = getSingleCellTracks2(rawdatapath, database, group, position, channel, centroids, ff_offset, ff_gain)
    trackedCells = centroids.getTrackedCellIds;
    numTracks = length(trackedCells);
    numTimepoints = length(centroids.singleCells);
        
    singleCellTracks = -ones(numTracks, numTimepoints);
    for i=1:numTimepoints
        fprintf('%d ', i);
        filename = getDatabaseFile2(database, group, channel, position, i);
        if(isempty(filename))
            continue;
        end
        YFP = double(imread(fullfile(rawdatapath, filename)));
        %YFP_background = imfilter(YFP, fspecial('gaussian', 30, 4));
        
        %YFP_ff = flatfield_correctImage(YFP, ff_offset, ff_gain);
        %YFP_background = imbackground(YFP_ff, 10, 50);
        %YFP_background = YFP_ff;
        %YFP_background = YFP;
        YFP_background = imbackground(YFP, 10, 50);
        %YFP_background = imfilter(YFP_background, fspecial('gaussian', 30, 4));
        
        [currentCentroids, validCells] = centroids.getCentroids(i);
        
        scalingFactor = 1;
        currentCentroids(:,1) = min(currentCentroids(:,1) * scalingFactor, size(YFP,1));
        currentCentroids(:,2) = min(currentCentroids(:,2) * scalingFactor, size(YFP,2));
        
        currentCentroids = sub2ind(size(YFP), currentCentroids(:,1), currentCentroids(:,2));
        mask = zeros(size(YFP));
        mask(currentCentroids) = validCells;
        mask = imdilate(mask, strel('disk', 7));
        measurements = regionprops(mask, YFP_background, 'MeanIntensity');
        
        measuredCells = ~isnan([measurements.MeanIntensity]);
        singleCellTracks(measuredCells, i) = [measurements(measuredCells).MeanIntensity];
        
        % Repeated values (divisions, for instance)
        if(length(currentCentroids) > 1)
            centroidFrequency = tabulate(currentCentroids);
            repeatedValues = centroidFrequency(centroidFrequency(:,2) > 1,1);
            for j=1:length(repeatedValues)
                repeatedIndexes = validCells(currentCentroids == repeatedValues(j));
                singleCellTracks(repeatedIndexes,i) = max(singleCellTracks(repeatedIndexes,i));
            end
        end
        
%         for j=1:length(validCells)
%             myCentroid = currentCentroids(j,:);
%             mask = zeros(size(YFP));
%             mask(myCentroid(1), myCentroid(2)) = 1;
%             mask = imdilate(mask, strel('disk', 5));
%             outputIndex = trackedCells(trackedCells == validCells(j));
%             singleCellTracks(outputIndex, i) = mean(YFP_background(logical(mask)));
%         end
    end
    fprintf('\n');
end