function measurements = getDatasetTraces_fromMeasurementTable(trackingPath, measurementsPath)
    % Identify tracking files
    trackingFiles = dir(trackingPath);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    % Define and preallocate output measurement matrices
    load(fullfile(trackingPath, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    templateMatrix = -ones(maxCells, numTimepoints);
    
    measurementFiles = dir(measurementsPath);
    measurementFiles = {measurementFiles(:).name};
    validFiles = regexp(measurementFiles, 'txt', 'once');
    measurementFiles = measurementFiles(~cellfun(@isempty, validFiles));
    preprocessedMeasurements = readtable(fullfile(measurementsPath, measurementFiles{1}), 'Delimiter', '\t');
    validColumns = find(~ismember(preprocessedMeasurements.Properties.VariableNames, {'group_label','position_number','timepoint'}));
    numMatrices = length(validColumns);

    measurementMatrix = repmat({templateMatrix}, numMatrices, 1);
    
    divisions = -ones(maxCells, numTimepoints);
    death = -ones(maxCells, numTimepoints);    
    lineageTree = -ones(maxCells, numTimepoints);
    cellAnnotation = cell(maxCells, 3);
    
    counter = 1;
    maxUniqueCellIdentifier = 0;
    for i=1:length(trackingFiles)
        fprintf('%s\n', trackingFiles{i});
        load(fullfile(trackingPath, trackingFiles{i}));
        
        measurement_file = sprintf('%s_s%d.txt', selectedGroup, selectedPosition);
        if(~exist(fullfile(measurementsPath, measurement_file), 'file'))
            fprintf('File %s does not exist. Position will be skipped\n', measurement_file);
            continue;
        end
        preprocessedMeasurements = readtable(fullfile(measurementsPath, measurement_file), 'Delimiter', '\t');
        validColumns = find(~ismember(preprocessedMeasurements.Properties.VariableNames, {'group_label','position_number','timepoint'}));
        
        trackedCells = centroidsTracks.getTrackedCellIds;
        templateMatrix = -ones(length(trackedCells), numTimepoints);
        currentMeasurements = repmat({templateMatrix},numMatrices,1);
        
        % For each timepoint
        for t=1:numTimepoints
            % Get all tracked centroids
            [currentCentroids, currentCells] = centroidsTracks.getCentroids(t);
            [~, currentCells] = ismember(currentCells, trackedCells); % This is vital to account for non-continuous cell ids
            subTable = preprocessedMeasurements(preprocessedMeasurements.timepoint == t,:);
            if(isempty(currentCentroids) || isempty(subTable))
                continue;
            end
            
            predictedCentroids = [subTable.centroid_row, subTable.centroid_col];
            
            % Load images, useful for debugging
            %IM = imread(fullfile('RAW_DATA', sprintf('Coculture_w1CFP_s%d_t%d.TIF', selectedPosition, t)));
            %figure; imagesc(IM); hold all;
            %plot(currentCentroids(:,2), currentCentroids(:,1), 'g*'); plot(predictedCentroids(:,1), predictedCentroids(:,2), 'g*');
            
            % Match each of these centroids with the cells identified and
            % quantified in the preprocessedMeasurements table
            [matchedIndex, ~] = knnsearch(predictedCentroids, currentCentroids);
            
            % Introduce all the values into the measurement matrix
            for j=1:numMatrices
                currentMeasurements{j}(currentCells,t) = subTable{matchedIndex,validColumns(j)};
            end
        end
        
        n = length(trackedCells);
        subsetIndex = counter:(counter + n - 1);
        
        % Fill lineage history information into each of the measured
        % matrices
        for j=1:numMatrices
            currentMeasurements{j} = fillLineageInformation(currentMeasurements{j}, centroidsTracks, centroidsDivisions);
            measurementMatrix{j}(subsetIndex,:) = currentMeasurements{j};
        end
        
        currentLineageTree = generateLineageTree(centroidsTracks, centroidsDivisions);
        currentLineageTree(currentLineageTree > 0) = currentLineageTree(currentLineageTree > 0) + maxUniqueCellIdentifier;
        maxUniqueCellIdentifier = max(currentLineageTree(:));
        
        currentDivisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        currentDeathMatrix = getDivisionMatrix(centroidsTracks, centroidsDeath);
        currentDivisionMatrix = fillLineageInformation(currentDivisionMatrix, centroidsTracks, centroidsDivisions);
        currentDeathMatrix = fillLineageInformation(currentDeathMatrix, centroidsTracks, centroidsDivisions);
        
        divisions(subsetIndex,:) = currentDivisionMatrix;
        death(subsetIndex,:) = currentDeathMatrix;
        lineageTree(subsetIndex,:) = currentLineageTree;
        
        cellAnnotation(subsetIndex,1) = repmat({selectedGroup}, n, 1);
        cellAnnotation(subsetIndex,2) = repmat({selectedPosition}, n, 1);
        trackedCells = centroidsTracks.getTrackedCellIds;
        for j =1:length(subsetIndex)
            cellAnnotation(subsetIndex(j),3) = {trackedCells(j)};
        end
        counter = counter + n;
    end
    
    % Trim unused rows that were preallocated
    for j=1:numMatrices
        measurementMatrix{j} = measurementMatrix{j}(1:(counter-1),:);
    end

    divisions = divisions(1:(counter-1),:);
    death = death(1:(counter-1),:);
    lineageTree = lineageTree(1:(counter-1),:);
    cellAnnotation = cellAnnotation(1:(counter-1),:);
    
    measurements.measurementMatrix = measurementMatrix;
    measurements.divisions = divisions;
    measurements.death = death;
    measurements.lineageTree = lineageTree;
    measurements.cellAnnotation = cellAnnotation;
end