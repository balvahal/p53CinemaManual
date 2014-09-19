function [singleCellTraces, cellAnnotation, divisionMatrixDataset, filledSingleCellTraces, filledDivisionMatrixDataset] = getDatasetTraces_fillLineageInformation(trackingPath,ffpath,channel)
    trackingFiles = dir(trackingPath);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(trackingPath, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    
    singleCellTraces = -ones(maxCells, numTimepoints);
    divisionMatrixDataset = -ones(maxCells, numTimepoints);
    filledDivisionMatrixDataset = -ones(maxCells, numTimepoints);
    filledSingleCellTraces = -ones(maxCells, numTimepoints);
    cellAnnotation = cell(maxCells, 3);
    
    % Prepare flatfield images
    if(~isempty(ffpath) && ~strcmp(ffpath, ''))
        [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, channel);
    else
        ff_offset = 0; ff_gain = 0;
    end
    
    counter = 1;
    for i=1:length(trackingFiles)
        load(fullfile(trackingPath, trackingFiles{i}));
        database = readtable(databaseFile, 'Delimiter', '\t');
        traces = getSingleCellTracks2(rawdatapath, database, selectedGroup, selectedPosition, channel, centroidsTracks, ff_offset, ff_gain);
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        filledTraces = fillLineageInformation(traces, centroidsDivisions);
        filledDivisionMatrix = fillLineageInformation(divisionMatrix, centroidsDivisions);
        
        n = length(centroidsTracks.getTrackedCellIds);

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
    singleCellTraces = singleCellTraces(1:(counter-1),:);
    divisionMatrixDataset = divisionMatrixDataset(1:(counter-1),:);
    filledDivisionMatrixDataset = filledDivisionMatrixDataset(1:(counter-1),:);
    filledSingleCellTraces = filledSingleCellTraces(1:(counter-1),:);    
    cellAnnotation = cellAnnotation(1:(counter-1),:);
end