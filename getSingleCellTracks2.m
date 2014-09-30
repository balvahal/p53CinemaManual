function singleCellTracks = getSingleCellTracks2(rawdatapath, database, group, position, channel, centroids, ff_offset, ff_gain)
    trackedCells = centroids.getTrackedCellIds;
    numTracks = length(trackedCells);
    numTimepoints = length(centroids.singleCells);
        
    singleCellTracks = -ones(numTracks, numTimepoints);
    for i=1:numTimepoints
        %fprintf('%d ', i);
        filename = getDatabaseFile2(database, group, channel, position, i);
        [currentCentroids, validCells] = centroids.getCentroids(i);
        if(isempty(filename) || isempty(validCells))
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

        scalingFactor = 1;
        currentCentroids(:,1) = min(ceil(currentCentroids(:,1) * scalingFactor), size(YFP,1));
        currentCentroids(:,2) = min(ceil(currentCentroids(:,2) * scalingFactor), size(YFP,2));
        
        currentCentroids = sub2ind(size(YFP), currentCentroids(:,1), currentCentroids(:,2));
        
        diskMask = getnhood(strel('disk',7));
        diskMask = diskMask / sum(diskMask(:));
        diskFilteredImage = imfilter(YFP_background, diskMask, 'replicate');
        singleCellTracks(validCells,i) = diskFilteredImage(currentCentroids);
    end
    %fprintf('\n');
end