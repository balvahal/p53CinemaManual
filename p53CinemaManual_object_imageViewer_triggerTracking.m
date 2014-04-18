function p53CinemaManual_object_imageViewer_triggerTracking(master,AnnotationEvent)
%%
if master.debugmode
    currentPoint = master.obj_imageViewer.getPixelxy;
    if ~isempty(currentPoint)
        mystr = sprintf('x = %d\ty = %d',currentPoint(1),currentPoint(2));
        disp(mystr);
    else
        mystr = sprintf('OUTSIDE AXES!!!');
        disp(mystr);
    end
end

currentPoint = master.obj_imageViewer.getPixelxy;
if(~master.obj_imageViewer.obj_cellTracker.isTracking)
    return;
end

currentPoint = master.obj_imageViewer.getPixelxy;
if(isempty(currentPoint))
    return;
end
% If the dataset has been preprocessed, perform tracking under
% "magnet mode"
if(master.obj_fileManager.preprocessMode)
    lookupRadius = master.obj_imageViewer.obj_cellTracker.getDistanceRadius;
    queryCentroid = master.obj_imageViewer.obj_cellTracker.centroidsLocalMaxima.getClosestCentroid(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
else
    queryCentroid = fliplr(currentPoint);
end
% If this is the first time the user clicks after starting a new
% track, define the selected cell
if(master.obj_imageViewer.obj_cellTracker.firstClick)
    lookupRadius = master.obj_imageViewer.obj_cellTracker.getDistanceRadius / 6;
    [cellCentroid1, cell_id1] = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getClosestCentroid(master.obj_imageViewer.currentTimepoint, queryCentroid, lookupRadius);
    [cellCentroid2, cell_id2] = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getClosestCentroid(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
    if(~isempty(cell_id2))
        master.obj_imageViewer.setSelectedCell(cell_id2);
        queryCentroid = cellCentroid2;
    elseif(~isempty(cell_id1))
        master.obj_imageViewer.setSelectedCell(cell_id1);
        queryCentroid = cellCentroid1;
    else
        master.obj_imageViewer.setSelectedCell(master.obj_imageViewer.obj_cellTracker.centroidsTracks.getAvailableCellId);
    end
    master.obj_imageViewer.obj_cellTracker.firstClick = 0;
end

master.obj_imageViewer.obj_cellTracker.centroidsTracks.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, queryCentroid, 1);
if(strcmp(AnnotationEvent, 'division'))
    master.obj_imageViewer.obj_cellTracker.centroidsDivisions.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, queryCentroid, 1);
elseif(strcmp(AnnotationEvent, 'death'))
    master.obj_imageViewer.obj_cellTracker.centroidsDeath.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, queryCentroid, 1);
end
master.obj_imageViewer.obj_cellTracker.setAvailableCells;

master.obj_imageViewer.setImage;
drawnow;
frameSkip = master.obj_imageViewer.obj_cellTracker.getFrameSkip;
master.obj_imageViewer.nextFrame;
end