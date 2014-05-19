function singleCellTracks = getSingleCellTracks2(rawdatapath, database, group, position, channel, centroids)
    trackedCells = centroids.getTrackedCellIds;
    numTracks = length(trackedCells);
    numTimepoints = length(centroids.singleCells);
    
    singleCellTracks = -ones(numTracks, numTimepoints);
    for i=1:numTimepoints
        fprintf('%d ', i);
        YFP = imread(fullfile(rawdatapath, getDatabaseFile2(database, group, channel, position, i)));
        YFP_background = imbackground(YFP, 10, 50);
        %YFP_background = imfilter(YFP_background, fspecial('gaussian', 30, 4));
        [currentCentroids, validCells] = centroids.getCentroids(i);
        for j=1:length(validCells)
            myCentroid = currentCentroids(j,:);
            mask = zeros(size(YFP));
            mask(myCentroid(1), myCentroid(2)) = 1;
            mask = imdilate(mask, strel('disk', 5));
            outputIndex = trackedCells(trackedCells == validCells(j));
            singleCellTracks(outputIndex, i) = mean(YFP_background(logical(mask)));
        end
    end
    fprintf('\n');
end