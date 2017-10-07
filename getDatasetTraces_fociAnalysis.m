function measurements = getDatasetTraces_fociAnalysis(database, rawdata_path, tracking_path, segment_path, ffpath, measurementChannel, segmentationChannel)
    trackingFiles = dir(tracking_path);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(tracking_path, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    
    singleCellTraces_foci = -ones(maxCells, numTimepoints);
    singleCellTraces_background = -ones(maxCells, numTimepoints);
    singleCellTraces_dilation = -ones(maxCells, numTimepoints);
    singleCellTraces_dilation_background = -ones(maxCells, numTimepoints);
    divisionMatrixDataset = -ones(maxCells, numTimepoints);
    filledDivisionMatrixDataset = -ones(maxCells, numTimepoints);
    filledSingleCellTraces_foci = -ones(maxCells, numTimepoints);
    filledSingleCellTraces_background = -ones(maxCells, numTimepoints);
    filledSingleCellTraces_dilation = -ones(maxCells, numTimepoints);
    filledSingleCellTraces_dilation_background = -ones(maxCells, numTimepoints);
    cellAnnotation = cell(maxCells, 3);
    
    % Prepare flatfield images
    if(~isempty(ffpath) && ~strcmp(ffpath, ''))
        [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, measurementChannel);
    else
        ff_offset = []; ff_gain = [];
    end

    counter = 1;
    for i=1:length(trackingFiles)
        fprintf('%s: ', trackingFiles{i});
        load(fullfile(tracking_path, trackingFiles{i}));
        [traces_foci, traces_background, traces_dilation, traces_dilation_background] = getSingleCellTrace_fociAnalysis(rawdata_path, segment_path, database, selectedGroup, selectedPosition, measurementChannel, segmentationChannel, centroidsTracks, ff_offset, ff_gain);
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        filledTraces_foci = fillLineageInformation(traces_foci, centroidsTracks, centroidsDivisions);
        filledTraces_background = fillLineageInformation(traces_background, centroidsTracks, centroidsDivisions);
        filledTraces_dilation = fillLineageInformation(traces_dilation, centroidsTracks, centroidsDivisions);
        filledTraces_dilation_background = fillLineageInformation(traces_dilation_background, centroidsTracks, centroidsDivisions);
        filledDivisionMatrix = fillLineageInformation(divisionMatrix, centroidsTracks, centroidsDivisions);
        
        n = size(traces_foci,1);

        subsetIndex = counter:(counter + n - 1);
        singleCellTraces_foci(subsetIndex,:) = traces_foci;
        singleCellTraces_background(subsetIndex,:) = traces_background;
        singleCellTraces_dilation(subsetIndex,:) = traces_dilation;
        singleCellTraces_dilation_background(subsetIndex,:) = traces_dilation_background;
        divisionMatrixDataset(subsetIndex,:) = divisionMatrix;
        filledDivisionMatrixDataset(subsetIndex,:) = filledDivisionMatrix;
        filledSingleCellTraces_foci(subsetIndex,:) = filledTraces_foci;
        filledSingleCellTraces_background(subsetIndex,:) = filledTraces_background;
        filledSingleCellTraces_dilation(subsetIndex,:) = filledTraces_dilation;
        filledSingleCellTraces_dilation_background(subsetIndex,:) = filledTraces_dilation_background;
        
        cellAnnotation(subsetIndex,1) = repmat({selectedGroup}, n, 1);
        cellAnnotation(subsetIndex,2) = repmat({selectedPosition}, n, 1);
        trackedCells = centroidsTracks.getTrackedCellIds;
        for j =1:length(subsetIndex)
            cellAnnotation(subsetIndex(j),3) = {trackedCells(j)};
        end
        counter = counter + n;
    end
    measurements.singleCellTraces_foci = singleCellTraces_foci(1:(counter-1),:);
    measurements.singleCellTraces_background = singleCellTraces_background(1:(counter-1),:);
    measurements.singleCellTraces_dilation = singleCellTraces_dilation(1:(counter-1),:);
    measurements.singleCellTraces_dilation_background = singleCellTraces_dilation_background(1:(counter-1),:);
    measurements.divisionMatrixDataset = divisionMatrixDataset(1:(counter-1),:);
    measurements.filledDivisionMatrixDataset = filledDivisionMatrixDataset(1:(counter-1),:);
    measurements.filledSingleCellTraces_foci = filledSingleCellTraces_foci(1:(counter-1),:);    
    measurements.filledSingleCellTraces_background = filledSingleCellTraces_background(1:(counter-1),:);    
    measurements.filledSingleCellTraces_dilation = filledSingleCellTraces_dilation(1:(counter-1),:);    
    measurements.filledSingleCellTraces_dilation_background = filledSingleCellTraces_dilation_background(1:(counter-1),:);    
    measurements.cellAnnotation = cellAnnotation(1:(counter-1),:);
end