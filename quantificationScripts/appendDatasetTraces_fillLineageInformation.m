function measurements = appendDatasetTraces_fillLineageInformation(database, rawdata_path, trackingPath, ffpath, channel, previousMeasurements)
    trackingFiles = dir(trackingPath);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(trackingPath, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 20000;
    
    singleCellTraces = -ones(maxCells, numTimepoints);
    divisionMatrixDataset = -ones(maxCells, numTimepoints);
    deathMatrixDataset = -ones(maxCells, numTimepoints);
    centroid_col = -ones(maxCells, numTimepoints);
    centroid_row = -ones(maxCells, numTimepoints);
    
    filledDivisionMatrixDataset = -ones(maxCells, numTimepoints);
    filledDeathMatrixDataset = -ones(maxCells, numTimepoints);    
    filledSingleCellTraces = -ones(maxCells, numTimepoints);
    
    lineageTree = -ones(maxCells, numTimepoints);
    cellAnnotation = cell(maxCells, 3);
    
    filledRows = size(previousMeasurements.singleCellTraces,1);
    singleCellTraces(1:filledRows,:) = previousMeasurements.singleCellTraces;
    divisionMatrixDataset(1:filledRows,:) = previousMeasurements.divisionMatrixDataset;
    deathMatrixDataset(1:filledRows,:) = previousMeasurements.deathMatrix;
    centroid_col(1:filledRows,:) = previousMeasurements.centroid_col;
    centroid_row(1:filledRows,:) = previousMeasurements.centroid_row;
    filledDivisionMatrixDataset(1:filledRows,:) = previousMeasurements.filledDivisionMatrixDataset;
    filledDeathMatrixDataset(1:filledRows,:) = previousMeasurements.filledDeathMatrix;
    filledSingleCellTraces(1:filledRows,:) = previousMeasurements.filledSingleCellTraces;
    lineageTree(1:filledRows,:) = previousMeasurements.lineageTree;
    cellAnnotation(1:filledRows,:) = previousMeasurements.cellAnnotation;
    
    % Prepare flatfield images
    if(~isempty(ffpath) && ~strcmp(ffpath, ''))
        [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, channel);
    else
        ff_offset = 0; ff_gain = 0;
    end
    
    counter = filledRows + 1;
    maxUniqueCellIdentifier = max(lineageTree(:,1));
    for i=1:length(trackingFiles)
        fprintf('%s: ', trackingFiles{i});
        load(fullfile(trackingPath, trackingFiles{i}));

        traces = getSingleCellTracks2(rawdata_path, database, selectedGroup, selectedPosition, channel, centroidsTracks, ff_offset, ff_gain);
        
        currentLineageTree = generateLineageTree(centroidsTracks, centroidsDivisions);
        currentLineageTree(currentLineageTree > 0) = currentLineageTree(currentLineageTree > 0) + maxUniqueCellIdentifier;
        maxUniqueCellIdentifier = max(currentLineageTree(:));
        
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        deathMatrix = getDivisionMatrix(centroidsTracks, centroidsDeath);
        filledTraces = fillLineageInformation(traces, centroidsTracks, centroidsDivisions);
        filledDivisionMatrix = fillLineageInformation(divisionMatrix, centroidsTracks, centroidsDivisions);
        filledDeathMatrix = fillLineageInformation(deathMatrix, centroidsTracks, centroidsDivisions);
        [centroid_col_matrix, centroid_row_matrix] = getCentroidMatrices(centroidsTracks);
        centroid_col_matrix = fillLineageInformation(centroid_col_matrix, centroidsTracks, centroidsDivisions);
        centroid_row_matrix = fillLineageInformation(centroid_row_matrix, centroidsTracks, centroidsDivisions);
        
        n = size(traces,1);

        subsetIndex = counter:(counter + n - 1);
        singleCellTraces(subsetIndex,:) = traces;
        divisionMatrixDataset(subsetIndex,:) = divisionMatrix;
        deathMatrixDataset(subsetIndex,:) = deathMatrix;
        filledDivisionMatrixDataset(subsetIndex,:) = filledDivisionMatrix;
        filledDeathMatrixDataset(subsetIndex,:) = filledDeathMatrix;
        filledSingleCellTraces(subsetIndex,:) = filledTraces;
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
    singleCellTraces = singleCellTraces(1:(counter-1),:);
    divisionMatrixDataset = divisionMatrixDataset(1:(counter-1),:);
    filledDivisionMatrixDataset = filledDivisionMatrixDataset(1:(counter-1),:);
    filledSingleCellTraces = filledSingleCellTraces(1:(counter-1),:);
    deathMatrixDataset = deathMatrixDataset(1:(counter-1),:);
    filledDeathMatrixDataset = filledDeathMatrixDataset(1:(counter-1),:);
    lineageTree = lineageTree(1:(counter-1),:);
    cellAnnotation = cellAnnotation(1:(counter-1),:);
    centroid_col = centroid_col(1:(counter-1),:);
    centroid_row = centroid_row(1:(counter-1),:);    
    
    measurements.singleCellTraces = singleCellTraces;
    measurements.divisionMatrixDataset = divisionMatrixDataset;
    measurements.filledDivisionMatrixDataset = filledDivisionMatrixDataset;
    measurements.filledSingleCellTraces = filledSingleCellTraces;
    measurements.deathMatrix = deathMatrixDataset;
    measurements.filledDeathMatrix = filledDeathMatrixDataset;
    measurements.lineageTree = lineageTree;
    measurements.cellAnnotation = cellAnnotation;
    measurements.centroid_col = centroid_col;
    measurements.centroid_row = centroid_row;
end