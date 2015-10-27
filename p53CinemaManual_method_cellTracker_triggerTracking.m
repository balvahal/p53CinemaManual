%%
%
function [] = p53CinemaManual_method_cellTracker_triggerTracking(obj_cellT,altEvent)
%% debug mode
% Shows the x and y of the location of the mouse within the imageViewer
% axes
if obj_cellT.master.debugmode
    currentRowCol = obj_cellT.master.obj_imageViewer.getPixelxy;
    if ~isempty(currentRowCol)
        mystr = sprintf('x = %d\ty = %d',currentRowCol(1),currentRowCol(2));
        disp(mystr);
    else
        mystr = sprintf('OUTSIDE AXES!!!');
        disp(mystr);
    end
end
%% check for tracking mode
% If tracking mode is not activated then don't do anything
if(~obj_cellT.isTracking)
    return;
end
%%
%
currentRowCol = obj_cellT.master.obj_imageViewer.getPixelRowCol;
currentTimepoint = obj_cellT.master.obj_imageViewer.currentTimepoint;
if(isempty(currentRowCol))
    return;
end
% If the dataset has been preprocessed, perform tracking under "magnet
% mode"
if(obj_cellT.master.obj_fileManager.preprocessMode)
    lookupRadius = obj_cellT.getDistanceRadius;
    [queryCentroid,d] = obj_cellT.centroidsTracks.getClosestCentroid(currentTimepoint, currentRowCol, 1);
    if(isempty(d))
        queryCentroid = obj_cellT.centroidsLocalMaxima.getClosestCentroid(currentTimepoint, currentRowCol, lookupRadius);
    end
        
else
    lookupRadius = obj_cellT.getDistanceRadius;
    queryCentroid = obj_cellT.centroidsTracks.getClosestCentroid(currentTimepoint, currentRowCol, 2);
end
% If this is the first time the user clicks after starting a new track,
% define the selected cell
if(obj_cellT.firstClick)
    lookupRadius = obj_cellT.getDistanceRadius / 6; % 6 was chosen empircally when comparing a 30 pixel radius search area with a 5 pixel radius selection area
    [cellCentroid1, cell_id1] = obj_cellT.centroidsTracks.getClosestCentroid(currentTimepoint, queryCentroid, lookupRadius);
    [cellCentroid2, cell_id2] = obj_cellT.centroidsTracks.getClosestCentroid(currentTimepoint, currentRowCol, 2);
    if(~isempty(cell_id2))
        obj_cellT.master.obj_imageViewer.setSelectedCell(cell_id2);
        queryCentroid = cellCentroid2;
    elseif(~isempty(cell_id1))
        obj_cellT.master.obj_imageViewer.setSelectedCell(cell_id1);
        queryCentroid = cellCentroid1;
    else
        obj_cellT.master.obj_imageViewer.setSelectedCell(obj_cellT.centroidsTracks.getAvailableCellId);
    end
    obj_cellT.firstClick = 0;
end

%% Set the centroids in selected cell and time
selectedCell = obj_cellT.master.obj_imageViewer.selectedCell;
if(strcmp(altEvent, 'alt')) % Override predictions if user used left click
    queryCentroid = currentRowCol;
end
obj_cellT.centroidsTracks.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
% Move centroid if there was one in division or death events
if(obj_cellT.centroidsDivisions.getValue(currentTimepoint, selectedCell))
    obj_cellT.centroidsDivisions.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
end
if(obj_cellT.centroidsDeath.getValue(currentTimepoint, selectedCell))
    obj_cellT.centroidsDeath.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
end
obj_cellT.setAvailableCells;

obj_cellT.master.obj_imageViewer.setImage;
drawnow;

% Try to propagate track until there is ambiguity
if(strcmp(obj_cellT.trackPropagateMode, 'SingleFramePropagate'))
    obj_cellT.master.obj_imageViewer.nextFrame;
    return;
end

master = obj_cellT.master;
lookupRadius = obj_cellT.getDistanceRadius;
selectedCell = master.obj_imageViewer.selectedCell;

if(strcmp(obj_cellT.trackPropagateMode, 'ForwardPropagate'))
    frameOrdering = master.obj_imageViewer.currentFrame:length(master.obj_fileManager.currentImageTimepoints);
else
    frameOrdering = fliplr(1:master.obj_imageViewer.currentFrame);
end

if(length(frameOrdering) > 1)
    for j=2:length(frameOrdering);
        currentTimepoint = master.obj_fileManager.currentImageTimepoints(frameOrdering(j));
        previousTimepoint = master.obj_fileManager.currentImageTimepoints(frameOrdering(j-1));
        previousCentroid = obj_cellT.centroidsTracks.getCentroid(previousTimepoint, selectedCell);
        currentCentroid = obj_cellT.centroidsTracks.getCentroid(currentTimepoint, selectedCell);
        if(currentCentroid(1) == 0)
            [predictedCentroids, ~, distance] = obj_cellT.centroidsLocalMaxima.getCentroidsInRange(currentTimepoint, previousCentroid, lookupRadius);
            if(length(distance) == 1)
                obj_cellT.centroidsTracks.setCentroid(currentTimepoint, selectedCell, predictedCentroids, 0);
            elseif(~isempty(distance))
                [sortedDistance, ordering] = sort(distance);
                if(diff(sortedDistance(1:2)) > lookupRadius / 2)
                    reciprocalCentroid = obj_cellT.centroidsLocalMaxima.getClosestCentroid(previousTimepoint, predictedCentroids(ordering(1),:), lookupRadius);
                    if(sum(reciprocalCentroid == currentCentroid) == 2)
                        obj_cellT.centroidsTracks.setCentroid(currentTimepoint, selectedCell, predictedCentroids(ordering(1),:), 0);
                    end
                else
                    break;
                end
            else
                break;
            end
        else
            break
        end
        master.obj_imageViewer.setFrame(frameOrdering(j));
        obj_cellT.master.obj_imageViewer.setImage;
        drawnow;
    end
    master.obj_imageViewer.setFrame(frameOrdering(j-1));
    master.obj_imageViewer.setFrame(frameOrdering(j));
end

obj_cellT.master.obj_imageViewer.setImage;
drawnow;
end