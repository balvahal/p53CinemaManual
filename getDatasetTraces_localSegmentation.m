function measurements = getDatasetTraces_localSegmentation(database, rawdata_path, tracking_path, ffpath, measurementChannels, segmentationChannel)
    trackingFiles = dir(tracking_path);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(tracking_path, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    
    if(~iscell(measurementChannels))
        measurementChannels = {measurementChannels};
    end
    
    if(~ismember(segmentationChannel, measurementChannels))
        measurementChannels = [measurementChannels, segmentationChannel];
    end
    
    singleCellTracks_mean = repmat({-ones(maxCells, numTimepoints)},1,length(measurementChannels));
    singleCellTracks_median = repmat({-ones(maxCells, numTimepoints)},1,length(measurementChannels));
    singleCellTracks_foci = repmat({-ones(maxCells, numTimepoints)},1,length(measurementChannels));

    singleCellTracks_area = -ones(maxCells, numTimepoints);
    divisionMatrixDataset = -ones(maxCells, numTimepoints);
    deathMatrixDataset = -ones(maxCells, numTimepoints);
    
    centroid_col = -ones(maxCells, numTimepoints);
    centroid_row = -ones(maxCells, numTimepoints);
    lineageTree = -ones(maxCells, numTimepoints);

    cellAnnotation = cell(maxCells, 3);
    
    % Prepare flatfield images
    if(~isempty(ffpath) && ~strcmp(ffpath, ''))
        for i=1:length(measurementChannels)
            [ff_offset{i}, ff_gain{i}] = flatfield_readFlatfieldImages(ffpath, measurementChannels{i});
        end
    else
        ff_offset = repmat({[]}, 1, length(measurementChannels)); ff_gain = repmat({[]}, 1, length(measurementChannels));
    end
    
    counter = 1;
    maxUniqueCellIdentifier = 0;
    for i=1:length(trackingFiles)
        fprintf('%s: ', trackingFiles{i});
        load(fullfile(tracking_path, trackingFiles{i}));
        [traces_mean, traces_median, traces_foci, traces_area] = getSingleCellTracks_localSegmentation(database, rawdata_path, selectedGroup, selectedPosition, measurementChannels, segmentationChannel, centroidsTracks, ff_offset, ff_gain);
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        deathMatrix = getDivisionMatrix(centroidsTracks, centroidsDeath);
        
        n = size(traces_mean{1},1);
        subsetIndex = counter:(counter + n - 1);
        
        for w=1:length(measurementChannels)
            traces_mean{w} = fillLineageInformation(traces_mean{w}, centroidsTracks, centroidsDivisions);
            traces_median{w} = fillLineageInformation(traces_median{w}, centroidsTracks, centroidsDivisions);
            traces_foci{w} = fillLineageInformation(traces_foci{w}, centroidsTracks, centroidsDivisions);
            
            singleCellTracks_mean{w}(subsetIndex,:) = traces_mean{w};
            singleCellTracks_median{w}(subsetIndex,:) = traces_median{w};
            singleCellTracks_foci{w}(subsetIndex,:) = traces_foci{w};
        end
        traces_area = fillLineageInformation(traces_area, centroidsTracks, centroidsDivisions);
        divisionMatrix = fillLineageInformation(divisionMatrix, centroidsTracks, centroidsDivisions);
        deathMatrix = fillLineageInformation(deathMatrix, centroidsTracks, centroidsDivisions);
        
        singleCellTracks_area(subsetIndex,:) = traces_area;
        divisionMatrixDataset(subsetIndex,:) = divisionMatrix;
        deathMatrixDataset(subsetIndex,:) = deathMatrix;
        
        currentLineageTree = generateLineageTree(centroidsTracks, centroidsDivisions);
        currentLineageTree(currentLineageTree > 0) = currentLineageTree(currentLineageTree > 0) + maxUniqueCellIdentifier;
        maxUniqueCellIdentifier = max(currentLineageTree(:));
        
        [centroid_col_matrix, centroid_row_matrix] = getCentroidMatrices(centroidsTracks);
        centroid_col_matrix = fillLineageInformation(centroid_col_matrix, centroidsTracks, centroidsDivisions);
        centroid_row_matrix = fillLineageInformation(centroid_row_matrix, centroidsTracks, centroidsDivisions);
        
        lineageTree(subsetIndex,:) = currentLineageTree;
        centroid_col(subsetIndex,:) = centroid_col_matrix;
        centroid_row(subsetIndex,:) = centroid_row_matrix;
        
        cellAnnotation(subsetIndex,1) = repmat({selectedGroup}, n, 1);
        cellAnnotation(subsetIndex,2) = repmat({selectedPosition}, n, 1);
        trackedCells = centroidsTracks.getTrackedCellIds;
        for j =1:length(subsetIndex)
            cellAnnotation(subsetIndex(j),3) = {trackedCells(j)};
        end
        counter = counter + n;
    end
    for w=1:length(measurementChannels)
        measurements.singleCellTracks_foci{w} = singleCellTracks_foci{w}(1:(counter-1),:);
        measurements.singleCellTracks_mean{w} = singleCellTracks_mean{w}(1:(counter-1),:);
        measurements.singleCellTracks_median{w} = singleCellTracks_median{w}(1:(counter-1),:);
    end
    measurements.singleCellTracks_area = singleCellTracks_area(1:(counter-1),:);
    measurements.divisionMatrixDataset = divisionMatrixDataset(1:(counter-1),:);
    measurements.deathMatrixDataset = deathMatrixDataset(1:(counter-1),:);
    measurements.centroid_col = centroid_col(1:(counter-1),:);    
    measurements.centroid_row = centroid_row(1:(counter-1),:);    
    measurements.lineageTree = lineageTree(1:(counter-1),:);    
    measurements.cellAnnotation = cellAnnotation(1:(counter-1),:);
    measurements.channels = measurementChannels;
end