function [singleCellTracks, backgroundTrace] = getSingleCellTracks_segmentationBackground(rawdatapath, database, position, channel, segmentationChannel, centroids, radius)
    trackedCells = centroids.getTrackedCellIds;
    numTracks = length(trackedCells);
    numTimepoints = length(centroids.singleCells);
    
    singleCellTracks = -ones(numTracks, numTimepoints);
    backgroundTrace = zeros(numTimepoints, 1);
    for i=1:numTimepoints
        fprintf('%d ', i);
        YFP = imread(fullfile(rawdatapath, getDatabaseFile(database, channel, position, i)));
        YFP = imfilter(YFP, fspecial('gaussian', radius, round(radius/4)), 'replicate');
        
%         Cy5 = imread(fullfile(rawdatapath, getDatabaseFile(database, segmentationChannel, position, i)));
%         [y,x] = hist(double(YFP(:)), 50);
%         [~, maxLoc] = max(y);
%         backgroundTrace(i) = x(maxLoc);
%         
%        YFP_background = YFP;
%        YFP_background = YFP - backgroundTrace(i);
       YFP_background = imbackground(YFP, 10, 50);
%         YFP_background = imfilter(YFP_background, fspecial('gaussian', 30, 4));
        [currentCentroids, validCells] = centroids.getCentroids(i);
        for j=1:length(validCells)
            myCentroid = currentCentroids(j,:);
            mask = zeros(size(YFP));
            mask(myCentroid(1), myCentroid(2)) = 1;
            mask = imdilate(mask, strel('disk', radius));
            outputIndex = trackedCells(trackedCells == validCells(j));
            singleCellTracks(outputIndex, i) = median(YFP_background(logical(mask)));
        end
    end
    fprintf('\n');
end