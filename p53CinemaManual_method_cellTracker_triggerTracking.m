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
    queryCentroid = obj_cellT.centroidsLocalMaxima.getClosestCentroid(currentTimepoint, currentRowCol, lookupRadius);
    queryCentroid = obj_cellT.centroidsTracks.getClosestCentroid(currentTimepoint, queryCentroid, lookupRadius);
else
    queryCentroid = currentRowCol;
end
% If this is the first time the user clicks after starting a new track,
% define the selected cell
if(obj_cellT.firstClick)
    lookupRadius = obj_cellT.getDistanceRadius / 6; % 6 was chosen empircally when comparing a 30 pixel radius search area with a 5 pixel radius selection area
    [cellCentroid1, cell_id1] = obj_cellT.centroidsTracks.getClosestCentroid(currentTimepoint, queryCentroid, lookupRadius);
    [cellCentroid2, cell_id2] = obj_cellT.centroidsTracks.getClosestCentroid(currentTimepoint, currentRowCol, lookupRadius);
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

% selectionType = altEvent;
% if(strcmp(selectionType, 'alt'))
%     annotationType = obj_cellT.cellFateEvent;
%     if(strcmp(annotationType, 'Division'))
%         obj_cellT.centroidsDivisions.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
%     end
%     if(strcmp(annotationType, 'Death'))
%         obj_cellT.centroidsDeath.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
%     end
% end

obj_cellT.master.obj_imageViewer.setImage;
drawnow;
frameSkip = obj_cellT.getFrameSkip;
obj_cellT.master.obj_imageViewer.nextFrame;
end