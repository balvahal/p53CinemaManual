function [singleCellTracks, backgroundTrace] = getSingleCellTracks2_flatfield_segmentation(rawdatapath, database, group, position, measured_channel, segmentation_channel, centroids, ff_offset, ff_gain)
    trackedCells = centroids.getTrackedCellIds;
    numTracks = length(trackedCells);
    numTimepoints = length(centroids.singleCells);
        
    singleCellTracks = -ones(numTracks, numTimepoints);
    backgroundTrace = zeros(3, numTimepoints);
    for i=1:numTimepoints
        fprintf('%d ', i);
        YFP = imread(fullfile(rawdatapath, getDatabaseFile2(database, group, measured_channel, position, i)));
        YFP_ff = flatfield_correctImage(YFP, ff_offset, ff_gain);
        %YFP_background = imbackground(YFP, 10, 50);
        %YFP_background = imfilter(YFP_background, fspecial('gaussian', 30, 4));

        RFP = imread(fullfile(rawdatapath, getDatabaseFile2(database, group, segmentation_channel, position, i)));
        nbin = 100;
        [y,x] = hist(double(RFP(:)),100);
        threshold = SEGMENTATION_TriangleMethod(y);
        Objects = imopen(imfill(RFP > x(threshold * nbin), 'holes'), strel('disk', 2));

        YFP_background = YFP_ff;
        backgroundTrace(1,i) = mean(YFP_ff(~imdilate(Objects, strel('disk', 3))));
        backgroundTrace(2,i) = median(YFP_ff(~imdilate(Objects, strel('disk', 3))));
        [~,maxLoc] = max(y);
        backgroundTrace(3,i) = x(maxLoc);
        
        YFP_background = YFP_ff - backgroundTrace(2,i);
        YFP_background(YFP_background < 0) = 0;
        
        [currentCentroids, validCells] = centroids.getCentroids(i);
        for j=1:length(validCells)
            myCentroid = currentCentroids(j,:);
            mask = zeros(size(YFP));
            mask(myCentroid(1), myCentroid(2)) = 1;
            %mask = imdilate(mask, strel('disk', 5)) .* Objects;
            mask = imdilate(mask, strel('disk', 5));
            outputIndex = trackedCells(trackedCells == validCells(j));
            singleCellTracks(outputIndex, i) = mean(YFP_background(logical(mask)));
        end
    end
    fprintf('\n');
end