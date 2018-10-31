classdef CentroidTimeseries_withAnnotations < handle
    % A data structure aimed to interact with p53Cinema. Useful functions
    % for storing sets of points associated with single cells in distinct
    % timepoints.
    
    properties
        singleCells;
        annotationNames;
    end
    
    methods
        function obj = CentroidTimeseries_withAnnotations(maxTimepoint, allocationSize, annotationNames)
            pointStructure.point = zeros(allocationSize, 2);
            pointStructure.value = zeros(allocationSize, 1);
            pointStructure.annotations = NaN *ones(allocationSize, length(annotationNames));
            obj.singleCells = repmat(pointStructure, maxTimepoint, 1);
            obj.annotationNames = annotationNames;
        end
        
        function setCentroid(obj, time, cell_id, centroid, value)
            obj.singleCells(time).point(cell_id,1) = max(0,centroid(1));
            obj.singleCells(time).point(cell_id,2) = max(0,centroid(2));
            obj.singleCells(time).value(cell_id) = value;
        end
        
        function setAnnotation(obj, time, cell_id, annotationIndex, annotationValue)
            if(annotationIndex <= length(obj.annotationNames))
                obj.singleCells(time).annotations(cell_id, annotationIndex) = annotationValue;
            end
        end
        
        % A function for inserting centroids from the initial index,
        % onwards
        function insertCentroids(obj, time, centroids)
            obj.singleCells(time).point(1:(size(centroids,1)),:) = centroids;
        end
        
        function centroid = getCentroid(obj, time, cell_id)
            centroid = obj.singleCells(time).point(cell_id,:);
        end
        
        % Get all non-zero centroids
        function [centroid, valid_cells] = getCentroids(obj, time)
            valid_cells = find(obj.singleCells(time).point(:,1) >0);
            centroid = obj.singleCells(time).point(valid_cells,:);
        end
        
        % Get all values for existing cells in a frame
        function [value, valid_cells] = getValues(obj, time)
            valid_cells = find(obj.singleCells(time).point(:,1) >0);
            value = obj.singleCells(time).value(valid_cells);
        end
        
        % Get all values for existing cells in a frame
        function [value, valid_cells] = getAnnotations(obj, time, annotationIndex)
            valid_cells = find(obj.singleCells(time).point(:,1) >0);
            if(annotationIndex <= length(obj.annotationNames))
                value = obj.singleCells(time).annotations(valid_cells, annotationIndex);
                valid_cells = valid_cells(~isnan(value));
                value = value(~isnan(value));
            end
        end
        
        function value = getValue(obj, time, cell_id)
            value = obj.singleCells(time).value(cell_id);
        end
        
        function value = getAnnotation(obj, time, cell_id, annotationIndex)
            value = NaN;
            if(annotationIndex <= length(obj.annotationNames))
                value = obj.singleCells(time).annotations(cell_id, annotationIndex);
            end
        end
        
        function track = getCellTrack(obj, cell_id)
            track = zeros(length(obj.singleCells),2);
            for i=1:length(obj.singleCells)
                track(i,:) = obj.getCentroid(i,cell_id);
            end
        end
        
        % Obtain the minimum available cell_id (one that has undefined centroids in all timepoints)
        function cell_id = getAvailableCellId(obj)
            cummulativeValue = zeros(size(obj.singleCells(1).point,1),1);
            for i=1:length(obj.singleCells)
                cummulativeValue = cummulativeValue + obj.singleCells(i).point(:,1);
            end
            cell_id = find(cummulativeValue == 0, 1, 'first');
            if(isempty(cell_id))
                cell_id = size(obj.singleCells(1).point,1) + 1;
            end
        end
        
        function cell_ids = getTrackedCellIds(obj)
            cummulativeValue = zeros(size(obj.singleCells(1).point,1),1);
            for i=1:length(obj.singleCells)
                cummulativeValue = cummulativeValue + obj.singleCells(i).point(:,1);
            end
            cell_ids = find(cummulativeValue > 0);
        end
        
        % Get closest centroid
        function [centroid, cell_id, distance] = getClosestCentroid(obj, time, queryCentroid, distanceRadius)
            [closeCentroids, closeCells, cellDistance] = obj.getCentroidsInRange(time, queryCentroid, distanceRadius);
            centroid = queryCentroid;
            cell_id = [];
            distance = Inf;
            if(~isempty(closeCentroids))
                [~, minLoc] = min(cellDistance);
                minLoc = minLoc(1);
                centroid = closeCentroids(minLoc,:);
                cell_id = closeCells(minLoc);
                distance = cellDistance(minLoc);
            end
            %centroid = queryCentroid;
        end
        
        % Get centroids in range
        function [centroids, cell_ids, distance] = getCentroidsInRange(obj, time, queryCentroid, distanceRadius)
            if(queryCentroid(:,1))
                [referenceCentroids, validCells] = obj.getCentroids(time);
            else
                referenceCentroids = [];
            end
            centroids = [];
            cell_ids = [];
            
            distance = [];
            if(~isempty(referenceCentroids))
                queryMatrix = repmat(queryCentroid, size(referenceCentroids,1), 1);
                distance = sum((queryMatrix - referenceCentroids) .^ 2, 2);
                distance = sqrt(distance);
                centroids = referenceCentroids(distance <= distanceRadius,:);
                cell_ids = validCells(distance <= distanceRadius);
                distance = distance(distance <= distanceRadius);
            end
        end
        
        function deleteTrack(obj, cell_id)
            if(cell_id > 0)
                for i=1:length(obj.singleCells)
                    obj.deleteCentroid(i,cell_id);
                end
            end
        end
        
        function deleteCentroid(obj, timepoint, cell_id)
            obj.singleCells(timepoint).point(cell_id,:) = [0,0];
            obj.singleCells(timepoint).value(cell_id,:) = 0;
            obj.singleCells(timepoint).annotations(cell_id,:) = NaN;
        end
        
    end
    
    
    
end

