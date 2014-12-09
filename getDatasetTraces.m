<<<<<<< HEAD
function [singleCellTraces, cellAnnotation, divisionMatrix] = getDatasetTraces(database, rawdata_path, trackingPath,ffpath,channel)
=======
function [singleCellTraces, cellAnnotation, divisionMatrix] = getDatasetTraces(trackingPath,ffpath,channel)
>>>>>>> origin/master
    trackingFiles = dir(trackingPath);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(trackingPath, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    
    singleCellTraces = -ones(maxCells, numTimepoints);
    divisionMatrix = -ones(maxCells, 10);
    cellAnnotation = cell(maxCells, 3);
    
    % Prepare flatfield images
    if(~isempty(ffpath) && ~strcmp(ffpath, ''))
        [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, channel);
    else
        ff_offset = 0; ff_gain = 0;
    end
    
    counter = 1;
    progress = 10;
    for i=1:length(trackingFiles)
        if(i/length(trackingFiles) * 100 > progress)
            fprintf('%d ', progress);
            progress = progress + 10;
        end
        load(fullfile(trackingPath, trackingFiles{i}));
<<<<<<< HEAD
        traces = getSingleCellTracks2(rawdata_path, database, selectedGroup, selectedPosition, channel, centroidsTracks, ff_offset, ff_gain);
=======
        database = readtable(databaseFile, 'Delimiter', '\t');
        traces = getSingleCellTracks2(rawdatapath, database, selectedGroup, selectedPosition, channel, centroidsTracks, ff_offset, ff_gain);
>>>>>>> origin/master
        n = length(centroidsTracks.getTrackedCellIds);
        
        subsetIndex = counter:(counter + n - 1);
        singleCellTraces(subsetIndex,1:size(traces,2)) = traces;
        cellAnnotation(subsetIndex,1) = repmat({selectedGroup}, n, 1);
        cellAnnotation(subsetIndex,2) = repmat({selectedPosition}, n, 1);
        trackedCells = centroidsTracks.getTrackedCellIds;
        for j =1:length(subsetIndex)
            cellAnnotation(subsetIndex(j),3) = {trackedCells(j)};
        end
        
        counter = counter + n;
    end
    fprintf('\n');
    singleCellTraces = singleCellTraces(1:(counter-1),:);
    cellAnnotation = cellAnnotation(1:(counter-1),:);
end