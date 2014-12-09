<<<<<<< HEAD
function [singleCellTraces, cellAnnotation, divisionMatrixDataset, filledSingleCellTraces, filledDivisionMatrixDataset, lineageTree] = getDatasetTraces_fillLineageInformation(database, rawdata_path,  trackingPath,ffpath,channel)
=======
function [singleCellTraces, cellAnnotation, divisionMatrixDataset, filledSingleCellTraces, filledDivisionMatrixDataset] = getDatasetTraces_fillLineageInformation(trackingPath,ffpath,channel)
>>>>>>> origin/master
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
<<<<<<< HEAD
    lineageTree = -ones(maxCells, numTimepoints);
=======
>>>>>>> origin/master
    cellAnnotation = cell(maxCells, 3);
    
    % Prepare flatfield images
    if(~isempty(ffpath) && ~strcmp(ffpath, ''))
        [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, channel);
    else
        ff_offset = 0; ff_gain = 0;
    end
    
    counter = 1;
<<<<<<< HEAD
    maxUniqueCellIdentifier = 0;
    for i=1:length(trackingFiles)
        fprintf('%s: ', trackingFiles{i});
        load(fullfile(trackingPath, trackingFiles{i}));

        traces = getSingleCellTracks2(rawdata_path, database, selectedGroup, selectedPosition, channel, centroidsTracks, ff_offset, ff_gain);
        
        currentLineageTree = generateLineageTree(centroidsTracks, centroidsDivisions);
        currentLineageTree(currentLineageTree > 0) = currentLineageTree(currentLineageTree > 0) + maxUniqueCellIdentifier;
        maxUniqueCellIdentifier = max(currentLineageTree(:));
        
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        %traces = divisionMatrix;

=======
    for i=1:length(trackingFiles)
        load(fullfile(trackingPath, trackingFiles{i}));
        database = readtable(databaseFile, 'Delimiter', '\t');
        traces = getSingleCellTracks2(rawdatapath, database, selectedGroup, selectedPosition, channel, centroidsTracks, ff_offset, ff_gain);
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
>>>>>>> origin/master
        filledTraces = fillLineageInformation(traces, centroidsDivisions);
        filledDivisionMatrix = fillLineageInformation(divisionMatrix, centroidsDivisions);
        
        n = length(centroidsTracks.getTrackedCellIds);

        subsetIndex = counter:(counter + n - 1);
        singleCellTraces(subsetIndex,:) = traces;
        divisionMatrixDataset(subsetIndex,:) = divisionMatrix;
        filledDivisionMatrixDataset(subsetIndex,:) = filledDivisionMatrix;
        filledSingleCellTraces(subsetIndex,:) = filledTraces;
<<<<<<< HEAD
        lineageTree(subsetIndex,:) = currentLineageTree;
=======
>>>>>>> origin/master
        
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
<<<<<<< HEAD
    filledSingleCellTraces = filledSingleCellTraces(1:(counter-1),:);
    lineageTree = lineageTree(1:(counter-1),:);
=======
    filledSingleCellTraces = filledSingleCellTraces(1:(counter-1),:);    
>>>>>>> origin/master
    cellAnnotation = cellAnnotation(1:(counter-1),:);
end