function singleCellTracks = getSingleCellTrace_withSegmentation_foci(rawdatapath, segmentationpath, database, group, position, measurementChannel, segmentationChannel, centroids)
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
    % Get measurement and segmentation files
    if(~isempty(measurementChannel))
        measurementFile = getDatabaseFile2(database, group, measurementChannel, position, i);
        if(isempty(measurementFile))
            continue;
        end
    else
        measurementFile = [];
    end
    if(~isempty(segmentationChannel))
        segmentFile = getDatabaseFile2(database, group, segmentationChannel, position, i);
    else
        segmentFile = [];
    end
    % Get current centroids
    [currentCentroids, validCells] = centroids.getCentroids(i);
    [~, validCells] = ismember(validCells, trackedCells);
    
    if(isempty(segmentFile) || isempty(validCells))
        continue;
    end
    % Read image and object files
    if(~isempty(segmentFile))
        %segmentFile = regexprep(segmentFile, '\.tiff', '_segment.TIF', 'ignoreCase');
        segmentFile = regexprep(segmentFile, '_w\d_*.*?_([st])', '_$1');
        %segmentFile = regexprep(segmentFile, '\..*', '.PNG');
        Objects = double(imread(fullfile(segmentationpath, segmentFile)));
    end
    if(~isempty(measurementFile))
        IntensityImage = double(imread(fullfile(rawdatapath, measurementFile)));
        IntensityImage = imbackground(IntensityImage, 10, 50);
    else
        IntensityImage = [];
    end

    scalingFactor = 1;
    currentCentroids(:,1) = min(currentCentroids(:,1) * scalingFactor, size(Objects,1));
    currentCentroids(:,2) = min(currentCentroids(:,2) * scalingFactor, size(Objects,2));
    
    measurements = regionprops_withKnownCentroids_fun(Objects, IntensityImage, currentCentroids, @std);
    singleCellTracks(validCells, i) = measurements(:,2);
    
    % Repeated values (divisions, for instance)
    currentCentroids = sub2ind(size(Objects), currentCentroids(:,1), currentCentroids(:,2));
    if(length(currentCentroids) > 1)
        centroidFrequency = tabulate(currentCentroids);
        repeatedValues = centroidFrequency(centroidFrequency(:,2) > 1,1);
        for j=1:length(repeatedValues)
            repeatedIndexes = validCells(currentCentroids == repeatedValues(j));
            singleCellTracks(repeatedIndexes,i) = max(singleCellTracks(repeatedIndexes,i));
        end
    end
end
fprintf('\n');
end