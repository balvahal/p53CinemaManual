function [singleCellTraces, cellAnnotation] = getDatasetTraces_flatfield_segmentation(trackingPath, ffpath, measured_channel, segmentation_channel)
    trackingFiles = dir(trackingPath);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(trackingPath, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    
    singleCellTraces = -ones(maxCells, numTimepoints);
    cellAnnotation = cell(maxCells, 3);
    
    [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, measured_channel);
    
    counter = 1;
    for i=1:length(trackingFiles)
        load(fullfile(trackingPath, trackingFiles{i}));
        database = readtable(databaseFile, 'Delimiter', '\t');
        traces = getSingleCellTracks2_flatfield_segmentation(rawdatapath, database, selectedGroup, selectedPosition, measured_channel, segmentation_channel, centroidsTracks, ff_offset, ff_gain);
        n = length(centroidsTracks.getTrackedCellIds);
        
        subsetIndex = counter:(counter + n - 1);
        singleCellTraces(subsetIndex,:) = traces;
        cellAnnotation(subsetIndex,1) = repmat({selectedGroup}, n, 1);
        cellAnnotation(subsetIndex,2) = repmat({selectedPosition}, n, 1);
        cellAnnotation(subsetIndex,3) = {centroidsTracks.getTrackedCellIds};
        
        counter = counter + n;
    end
    singleCellTraces = singleCellTraces(1:(counter-1),:);
    cellAnnotation = cellAnnotation(1:(counter-1),:);
    
end