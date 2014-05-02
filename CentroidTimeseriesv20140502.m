classdef CentroidTimeseries < handle
    % A data structure aimed to interact with p53Cinema. Useful functions
    % for storing sets of points associated with single cells in distinct
    % timepoints.
    
    properties
        singleCells;
    end
    
    methods
        function obj = CentroidTimeseries(maxTimepoint, allocationSize)
            pointStructure.point = zeros(allocationSize, 2);
            pointStructure.value = zeros(allocationSize, 1);
            obj.singleCells = repmat(pointStructure, maxTimepoint, 1);
        end
        
        function setCentroid(obj, time, cell_id, centroid, value)
            obj.singleCells(time).point(cell_id,:) = centroid;
            obj.singleCells(time).value(cell_id) = value;
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
        
        function value = getValue(obj, time, cell_id)
            value = obj.singleCells(time).value(cell_id);
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
                    obj.singleCells(i).point(cell_id,:) = [0,0];
                end
            end
        end
        
    end
    
    
    
end

