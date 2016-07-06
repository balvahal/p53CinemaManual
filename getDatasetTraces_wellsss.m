function measurements = getDatasetTraces_wellsss(trackingPath, wellsss_path)
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
    
    wellsssFiles = dir(wellsss_path);
    wellsssFiles = {wellsssFiles(:).name};
    validFiles = regexp(wellsssFiles, 'wellsss', 'once');
    wellsssFiles = wellsssFiles(~cellfun(@isempty, validFiles));
    load(fullfile(wellsss_path, wellsssFiles{1}));
    numMatrices = size(wellsss{1}, 2);
    
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
        
        wellsss_file = sprintf('wellsss_s%d.mat', selectedPosition);
        if(~exist(fullfile(wellsss_path, wellsss_file), 'file'))
            fprintf('File %s does not exist. Position will be skipped\n', wellsss_file);
            continue;
        end
        load(fullfile(wellsss_path, wellsss_file));
        
        trackedCells = centroidsTracks.getTrackedCellIds;
        templateMatrix = -ones(length(trackedCells), numTimepoints);
        currentMeasurements = repmat({templateMatrix},numMatrices,1);
        
        % For each timepoint
        for t=1:numTimepoints
            % Get all tracked centroids
            [currentCentroids, currentCells] = centroidsTracks.getCentroids(t);
            if(isempty(currentCentroids) || length(wellsss) < t)
                continue;
            end
            predictedCentroids = wellsss{t}(:,1:2);
            predictedCentroids = fliplr(predictedCentroids);
            
            % Load images, useful for debugging
            %IM = imread(fullfile('RAW_DATA', sprintf('Coculture_w1CFP_s%d_t%d.TIF', selectedPosition, t)));
            %figure; imagesc(IM); hold all;
            %plot(currentCentroids(:,2), currentCentroids(:,1), 'g*'); plot(predictedCentroids(:,1), predictedCentroids(:,2), 'g*');
            
            % Match each of these centroids with the cells identified and
            % quantified in wellsss
            [matchedIndex, ~] = knnsearch(predictedCentroids, currentCentroids);
            
            % Introduce all the values into the measurement matrix
            for j=1:numMatrices
                currentMeasurements{j}(currentCells,t) = wellsss{t}(matchedIndex,j);
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