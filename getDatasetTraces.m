function [singleCellTraces, cellAnnotation] = getDatasetTraces(trackingPath)
    trackingFiles = dir(trackingPath);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(trackingPath, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    
    singleCellTraces = -ones(maxCells, numTimepoints);
    cellAnnotation = cell(maxCells, 3);
    
    counter = 1;
    for i=1:length(trackingFiles)
        load(fullfile(trackingPath, trackingFiles{i}));
        database = readtable(databaseFile, 'Delimiter', '\t');
        traces = getSingleCellTracks2(rawdatapath, database, selectedGroup, selectedPosition, 'YFP', centroidsTracks);
        n = size(traces,1);
        
        subsetIndex = counter:(counter + n - 1);
        singleCellTraces(subsetIndex,:) = traces;
        cellAnnotation(subsetIndex,1) = repmat({selectedGroup}, n, 1);
        cellAnnotation(subsetIndex,2) = repmat(selectedPosition, n, 1);
        cellAnnotation(subsetIndex,3) = centroidsTracks.getTrackedCellIds;
        
        counter = counter + 1;
    end
    singleCellTraces = singleCellTraces(1:(counter-1),:);
    cellAnnotation = cellAnnotation(1:(counter-1),:);
    
end