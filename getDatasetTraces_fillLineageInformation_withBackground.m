function measurements = getDatasetTraces_fillLineageInformation(database, rawdata_path, trackingPath, ffpath, channel)
    trackingFiles = dir(trackingPath);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(trackingPath, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    
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
    
    % Prepare flatfield images
    if(~isempty(ffpath) && ~strcmp(ffpath, ''))
        [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, channel);
    else
        ff_offset = 0; ff_gain = 0;
    end
    
    counter = 1;
    maxUniqueCellIdentifier = 0;
    background_traces = zeros(length(trackingFiles), numTimepoints);
    for i=1:length(trackingFiles)
        fprintf('%s: ', trackingFiles{i});
        load(fullfile(trackingPath, trackingFiles{i}));

        [traces, background_trace] = getSingleCellTracks2_withBackground(rawdata_path, database, selectedGroup, selectedPosition, channel, centroidsTracks, ff_offset, ff_gain);
        background_traces(i,:) = background_trace;
        filledTraces = fillLineageInformation(traces, centroidsTracks, centroidsDivisions);
        
        currentLineageTree = generateLineageTree(centroidsTracks, centroidsDivisions);
        currentLineageTree(currentLineageTree > 0) = currentLineageTree(currentLineageTree > 0) + maxUniqueCellIdentifier;
        maxUniqueCellIdentifier = max(currentLineageTree(:));
        
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        deathMatrix = getDivisionMatrix(centroidsTracks, centroidsDeath);
        filledDivisionMatrix = fillLineageInformation(divisionMatrix, centroidsTracks, centroidsDivisions);
        filledDeathMatrix = fillLineageInformation(deathMatrix, centroidsTracks, centroidsDivisions);
        [centroid_col_matrix, centroid_row_matrix] = getCentroidMatrices(centroidsTracks);
        centroid_col_matrix = fillLineageInformation(centroid_col_matrix, centroidsTracks, centroidsDivisions);
        centroid_row_matrix = fillLineageInformation(centroid_row_matrix, centroidsTracks, centroidsDivisions);
        
        n = size(divisionMatrix,1);
        
        % Dont measure traces
%         traces = zeros(n,numTimepoints);
%         filledTraces = fillLineageInformation(traces, centroidsTracks, centroidsDivisions);

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
    measurements.background = background_traces;
end