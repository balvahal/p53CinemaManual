function measurements = getDatasetTraces_fillLineageInformation_withSegmentation(database, rawdata_path, tracking_path, segment_path, ffpath, measurementChannel, segmentationChannel, measurementParameter)
    trackingFiles = dir(tracking_path);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(tracking_path, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    
    singleCellTraces = -ones(maxCells, numTimepoints);
    divisionMatrixDataset = -ones(maxCells, numTimepoints);
    filledDivisionMatrixDataset = -ones(maxCells, numTimepoints);
    filledSingleCellTraces = -ones(maxCells, numTimepoints);
    cellAnnotation = cell(maxCells, 3);
    
    if(~isempty(ffpath) && ~strcmp(ffpath, ''))
        [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, channel);
    else
        ff_offset = []; ff_gain = [];
    end

    counter = 1;
    for i=1:length(trackingFiles)
        fprintf('%s: ', trackingFiles{i});
        load(fullfile(tracking_path, trackingFiles{i}));
        traces = getSingleCellTrace_withSegmentation(rawdata_path, segment_path, database, selectedGroup, selectedPosition, measurementChannel, segmentationChannel, centroidsTracks, measurementParameter, ff_offset, ff_gain);
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        filledTraces = fillLineageInformation(traces, centroidsTracks, centroidsDivisions);
        filledDivisionMatrix = fillLineageInformation(divisionMatrix, centroidsTracks, centroidsDivisions);
        
        n = size(traces,1);

        subsetIndex = counter:(counter + n - 1);
        singleCellTraces(subsetIndex,:) = traces;
        divisionMatrixDataset(subsetIndex,:) = divisionMatrix;
        filledDivisionMatrixDataset(subsetIndex,:) = filledDivisionMatrix;
        filledSingleCellTraces(subsetIndex,:) = filledTraces;
        
        cellAnnotation(subsetIndex,1) = repmat({selectedGroup}, n, 1);
        cellAnnotation(subsetIndex,2) = repmat({selectedPosition}, n, 1);
        trackedCells = centroidsTracks.getTrackedCellIds;
        for j =1:length(subsetIndex)
            cellAnnotation(subsetIndex(j),3) = {trackedCells(j)};
        end
        counter = counter + n;
    end
    measurements.singleCellTraces = singleCellTraces(1:(counter-1),:);
    measurements.divisionMatrixDataset = divisionMatrixDataset(1:(counter-1),:);
    measurements.filledDivisionMatrixDataset = filledDivisionMatrixDataset(1:(counter-1),:);
    measurements.filledSingleCellTraces = filledSingleCellTraces(1:(counter-1),:);    
    measurements.cellAnnotation = cellAnnotation(1:(counter-1),:);
end