function measurements = getDatasetTraces_annotations(trackingPath)
    trackingFiles = dir(trackingPath);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    load(fullfile(trackingPath, trackingFiles{1}));
    numTimepoints = length(centroidsTracks.singleCells);
    maxCells = 10000;
    
    if(exist('annotationNames', 'var'))
        definedAnnotationNames = annotationNames;
    else
        definedAnnotationNames = {};
    end
    
    filledDivisionMatrixDataset = -ones(maxCells, numTimepoints);
    filledDeathMatrixDataset = -ones(maxCells, numTimepoints);
    centroid_col = -ones(maxCells, numTimepoints);
    centroid_row = -ones(maxCells, numTimepoints);
    filledCellFateMatrix = repmat({filledDivisionMatrixDataset}, length(definedAnnotationNames), 1);    
        
    lineageTree = -ones(maxCells, numTimepoints);
    cellAnnotation = cell(maxCells, 3);
        
    counter = 1;
    maxUniqueCellIdentifier = 0;
    for i=1:length(trackingFiles)
        fprintf('%s\n', trackingFiles{i});
        load(fullfile(trackingPath, trackingFiles{i}));
        
        currentLineageTree = generateLineageTree(centroidsTracks, centroidsDivisions);
        currentLineageTree(currentLineageTree > 0) = currentLineageTree(currentLineageTree > 0) + maxUniqueCellIdentifier;
        newUniqueCellIdentifier = max(currentLineageTree(:));
        
        currentLineageTree = generateLineageTree_uniqueCellCycleIdentifier(centroidsTracks, centroidsDivisions);
        currentLineageTree(currentLineageTree > 0) = currentLineageTree(currentLineageTree > 0) + maxUniqueCellIdentifier;
        
        maxUniqueCellIdentifier = newUniqueCellIdentifier;
        
        divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions);
        deathMatrix = getDivisionMatrix(centroidsTracks, centroidsDeath);
        filledDivisionMatrix = fillLineageInformation(divisionMatrix, centroidsTracks, centroidsDivisions);
        filledDeathMatrix = fillLineageInformation(deathMatrix, centroidsTracks, centroidsDivisions);
        [centroid_col_matrix, centroid_row_matrix] = getCentroidMatrices(centroidsTracks);
        
        n = size(divisionMatrix,1);
        
        subsetIndex = counter:(counter + n - 1); counter = counter + n;

        filledDivisionMatrixDataset(subsetIndex,:) = filledDivisionMatrix;
        filledDeathMatrixDataset(subsetIndex,:) = filledDeathMatrix;
        lineageTree(subsetIndex,:) = currentLineageTree;
        centroid_col(subsetIndex,:) = centroid_col_matrix;
        centroid_row(subsetIndex,:) = centroid_row_matrix;

        cellAnnotation(subsetIndex,1) = repmat({selectedGroup}, n, 1);
        cellAnnotation(subsetIndex,2) = repmat({selectedPosition}, n, 1);
        trackedCells = centroidsTracks.getTrackedCellIds;
        for j =1:length(subsetIndex)
            cellAnnotation(subsetIndex(j),3) = {trackedCells(j)};
        end

        for j=1:length(annotationNames)
            [~, annotationIndex] = ismember(annotationNames{j}, definedAnnotationNames);
            if(~isempty(annotationIndex))
                annotationMatrix = getCellFateEventMatrix(centroidsTracks, annotationIndex);
                annotationMatrix = fillLineageInformation(annotationMatrix, centroidsTracks, centroidsDivisions);
                filledCellFateMatrix{j}(subsetIndex,:) = annotationMatrix;
            end
        end
        
    end
    filledDivisionMatrixDataset = filledDivisionMatrixDataset(1:(counter-1),:);
    filledDeathMatrixDataset = filledDeathMatrixDataset(1:(counter-1),:);
    lineageTree = lineageTree(1:(counter-1),:);
    cellAnnotation = cellAnnotation(1:(counter-1),:);
    centroid_col = centroid_col(1:(counter-1),:);
    centroid_row = centroid_row(1:(counter-1),:);
    for j=1:length(annotationNames)
        filledCellFateMatrix{j} = filledCellFateMatrix{j}(1:(counter-1),:);
    end
    
    measurements.filledDivisionMatrixDataset = filledDivisionMatrixDataset;
    measurements.filledCellFateMatrix = filledCellFateMatrix;
    measurements.filledDeathMatrix = filledDeathMatrixDataset;
    measurements.lineageTree = lineageTree;
    measurements.cellAnnotation = cellAnnotation;
    measurements.centroid_col = centroid_col;
    measurements.centroid_row = centroid_row;
    measurements.annotationNames = annotationNames;
end