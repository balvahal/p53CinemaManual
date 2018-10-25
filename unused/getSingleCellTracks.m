function singleCellTracks = getSingleCellTracks(rawdatapath, database, position, channel, centroids)
    trackedCells = centroids.getTrackedCellIds;
    numTracks = length(trackedCells);
    numTimepoints = length(centroids.singleCells);
    
    singleCellTracks = -ones(numTracks, numTimepoints);
    for i=1:numTimepoints
        fprintf('%d ', i);
        YFP = imread(fullfile(rawdatapath, getDatabaseFile(database, channel, position, i)));
        YFP_background = YFP;
%         YFP_background = imbackground(YFP, 20, 100);
%         YFP_background = imfilter(YFP_background, fspecial('gaussian', 30, 4));
        [currentCentroids, validCells] = centroids.getCentroids(i);
        for j=1:length(validCells)
            myCentroid = currentCentroids(j,:);
            mask = zeros(size(YFP));
            mask(myCentroid(1), myCentroid(2)) = 1;
            mask = imdilate(mask, strel('disk', 50));
            outputIndex = trackedCells(trackedCells == validCells(j));
            singleCellTracks(outputIndex, i) = median(YFP_background(logical(mask)));
        end
    end
    fprintf('\n');
end