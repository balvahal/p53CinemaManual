function measurements = getDatasetTraces_localSegmentation_stacks_foci(database, rawdata_path, tracking_path, ffpath, measurementChannels, segmentationChannel, varargin)
    if(nargin > 6)
        separateCells = varargin{1};
    else
        separateCells = 1;
    end
    trackingFiles = dir(tracking_path);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    if(~exist('SEGMENT_DATA', 'dir'))
        mkdir('SEGMENT_DATA');
    end
    
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
    singleCellTracks_dilated = repmat({-ones(maxCells, numTimepoints)},1,length(measurementChannels));
    singleCellTracks_integrated = repmat({-ones(maxCells, numTimepoints)},1,length(measurementChannels));
    singleCellTracks_ratio = repmat({-ones(maxCells, numTimepoints)},1,length(measurementChannels));
    singleCellTracks_variance = repmat({-ones(maxCells, numTimepoints)},1,length(measurementChannels));
    singleCellTracks_distance = repmat({-ones(maxCells, numTimepoints)},1,length(measurementChannels));

    singleCellTracks_area = -ones(maxCells, numTimepoints);
    singleCellTracks_solidity = -ones(maxCells, numTimepoints);
    singleCellTracks_radius = -ones(maxCells, numTimepoints);
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
        segmentationOutput = fullfile('SEGMENT_DATA', sprintf('%s_w%s_s%d_segment.TIF', selectedGroup, segmentationChannel, selectedPosition));
        if(exist(segmentationOutput, 'file'))
            [results, segmentationResults] = getSingleCellTracks_localSegmentation_stacks_foci(database, rawdata_path, selectedGroup, selectedPosition, measurementChannels, segmentationChannel, centroidsTracks, ff_offset, ff_gain, separateCells, segmentationOutput);
        else
            [results, segmentationResults] = getSingleCellTracks_localSegmentation_stacks_foci(database, rawdata_path, selectedGroup, selectedPosition, measurementChannels, segmentationChannel, centroidsTracks, ff_offset, ff_gain, separateCells);            
        end
        
        if(~exist(segmentationOutput, 'file'))
            for t=1:size(segmentationResults,3)
                imwrite(uint8(segmentationResults(:,:,t)), segmentationOutput, 'WriteMode', 'Append');
            end
        end
                
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        deathMatrix = getDivisionMatrix(centroidsTracks, centroidsDeath);
        
        n = size(results.singleCellTracks_mean{1},1);
        subsetIndex = counter:(counter + n - 1);
        
        for w=1:length(measurementChannels)        
            singleCellTracks_mean{w}(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_mean{w}, centroidsTracks, centroidsDivisions);
            singleCellTracks_median{w}(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_median{w}, centroidsTracks, centroidsDivisions);
            singleCellTracks_foci{w}(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_foci{w}, centroidsTracks, centroidsDivisions);
            singleCellTracks_dilated{w}(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_dilated{w}, centroidsTracks, centroidsDivisions);
            singleCellTracks_integrated{w}(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_integrated{w}, centroidsTracks, centroidsDivisions);
            singleCellTracks_ratio{w}(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_ratio{w}, centroidsTracks, centroidsDivisions);
            singleCellTracks_variance{w}(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_variance{w}, centroidsTracks, centroidsDivisions);
            singleCellTracks_distance{w}(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_distance{w}, centroidsTracks, centroidsDivisions);
        end
        divisionMatrix = fillLineageInformation(divisionMatrix, centroidsTracks, centroidsDivisions);
        deathMatrix = fillLineageInformation(deathMatrix, centroidsTracks, centroidsDivisions);
        
        singleCellTracks_area(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_area, centroidsTracks, centroidsDivisions);
        singleCellTracks_solidity(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_solidity, centroidsTracks, centroidsDivisions);
        singleCellTracks_radius(subsetIndex,:) = fillLineageInformation(results.singleCellTracks_radius, centroidsTracks, centroidsDivisions);
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
        
        for w=1:length(measurementChannels)
            measurements.singleCellTracks_foci{w} = singleCellTracks_foci{w}(1:(counter-1),:);
            measurements.singleCellTracks_mean{w} = singleCellTracks_mean{w}(1:(counter-1),:);
            measurements.singleCellTracks_median{w} = singleCellTracks_median{w}(1:(counter-1),:);
            measurements.singleCellTracks_dilated{w} = singleCellTracks_dilated{w}(1:(counter-1),:);
            measurements.singleCellTracks_integrated{w} = singleCellTracks_integrated{w}(1:(counter-1),:);
            measurements.singleCellTracks_ratio{w} = singleCellTracks_ratio{w}(1:(counter-1),:);
            measurements.singleCellTracks_variance{w} = singleCellTracks_variance{w}(1:(counter-1),:);
            measurements.singleCellTracks_distance{w} = singleCellTracks_distance{w}(1:(counter-1),:);
        end
        measurements.singleCellTracks_area = singleCellTracks_area(1:(counter-1),:);
        measurements.singleCellTracks_solidity = singleCellTracks_solidity(1:(counter-1),:);
        measurements.singleCellTracks_radius = singleCellTracks_radius(1:(counter-1),:);
        measurements.divisionMatrixDataset = divisionMatrixDataset(1:(counter-1),:);
        measurements.deathMatrixDataset = deathMatrixDataset(1:(counter-1),:);
        measurements.centroid_col = centroid_col(1:(counter-1),:);
        measurements.centroid_row = centroid_row(1:(counter-1),:);
        measurements.lineageTree = lineageTree(1:(counter-1),:);
        measurements.cellAnnotation = cellAnnotation(1:(counter-1),:);
        measurements.channels = measurementChannels;
        
        save('temp_measurements.mat', 'measurements');
        
    end
    
end