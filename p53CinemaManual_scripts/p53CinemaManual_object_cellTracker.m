%%
%
classdef p53CinemaManual_object_cellTracker < handle
    properties
        gui_cellTracker;
        master;
        
        distanceRadius;
        frameSkip;
        
        isTracking;
        isPaused;
        firstClick;
        trackingDirection;
        trackingStyle;
        trackingDelay;
        playWhileTracking;
        
        centroidsLocalMaxima;
        centroidsTracks;
        centroidsDivisions;
        centroidsDeath;
        
    end
    events
        
    end
    methods
        %% Constructor
        function obj = p53CinemaManual_object_cellTracker(master)
            obj.gui_cellTracker = p53CinemaManual_gui_cellTracker(master);
            obj.centroidsTracks = CentroidTimeseries_withAnnotations(master.obj_fileManager.maxTimepoint, 10000, master.additionalAnnotationNames);
            obj.centroidsLocalMaxima = CentroidTimeseries(master.obj_fileManager.maxTimepoint, 10000);
            obj.centroidsDivisions = CentroidTimeseries(master.obj_fileManager.maxTimepoint, 10000);
            obj.centroidsDeath = CentroidTimeseries(master.obj_fileManager.maxTimepoint, 10000);
            obj.master = master;
            
            obj.isTracking = 0;
            obj.isPaused = 0;
            obj.firstClick = 1;
            obj.trackingStyle = 'SingleFramePropagate';
            obj.trackingDirection = 'Forward';
            obj.trackingDelay = 0;
            obj.playWhileTracking = 1;
            
        end
        function setAvailableCells(obj)
            availableCells = obj.centroidsTracks.getTrackedCellIds;
            selectedCell = obj.master.obj_imageViewer.selectedCell;
            handles = guidata(obj.gui_cellTracker);
            
            if(~isempty(availableCells))
                set(handles.hpopupSelectedCell, 'String', availableCells);
                selectedIndex = find(availableCells == selectedCell);
                if(~isempty(selectedIndex))
                    set(handles.hpopupSelectedCell, 'Value', selectedIndex);
                else
                    set(handles.hpopupSelectedCell, 'Value', 1);
                end
                set(handles.hpopupSelectedCell, 'Enable', 'on');
            else
                set(handles.hpopupSelectedCell, 'String', '-- Select cell --');
                set(handles.hpopupSelectedCell, 'Enable', 'off');
            end
        end
        
        function stopTracking(obj)
            handles = guidata(obj.gui_cellTracker);
            set(handles.htogglebuttonTrackingMode, 'Value', 0);
            obj.isTracking = 0;
        end
        
        function radius = getDistanceRadius(obj)
            handles = guidata(obj.gui_cellTracker);
            radius = str2double(get(handles.heditDistanceRadius, 'String'));
        end
        
        function radius = getFrameSkip(obj)
            handles = guidata(obj.gui_cellTracker);
            radius = str2double(get(handles.heditFrameSkip, 'String'));
        end
        
        function [] = setDivisionEvent(obj)
            centroid = obj.centroidsTracks.getCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell);
            if(centroid(1) > 0)
                obj.centroidsDivisions.setCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell, centroid, 1);
                obj.centroidsTracks.setCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell, centroid, 1);
            end
        end
        
        function [] = setDeathEvent(obj)
            centroid = obj.centroidsTracks.getCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell);
            if(centroid(1) > 0)
                obj.centroidsDeath.setCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell, centroid, 1);
            end
        end
        
        function triggerTracking(obj, altEvent)
            p53CinemaManual_method_cellTracker_triggerTracking(obj,altEvent);
        end
        
        function setEnableMerge(obj, status)
            h = guidata(obj.gui_cellTracker);
            set(h.hmergePushbutton, 'Enable', status);
        end
        
        function setEnableSplit(obj, status)
            h = guidata(obj.gui_cellTracker);
            set(h.hsplitPushbutton, 'Enable', status);
        end
        
        function deleteCellData(obj, cell_id)
            obj.deleteCellTimepoints(cell_id, 1:length(obj.centroidsTracks.singleCells));
        end
        
        function deleteCellTimepoints(obj, cell_id, timepoints)
            for i=timepoints
                obj.centroidsTracks.setCentroid(i, cell_id, [0,0], 0);
                obj.centroidsDivisions.setCentroid(i, cell_id, [0,0], 0);
                obj.centroidsDeath.setCentroid(i, cell_id, [0,0], 0);
            end
        end
        
        function findCells(obj, blurRadius)
            obj.centroidsLocalMaxima.delete;
            obj.centroidsLocalMaxima = CentroidTimeseries(obj.master.obj_fileManager.maxTimepoint, 10000);
            
            handles = guidata(obj.gui_cellTracker);
            set(handles.hprogressbarhandleFindCells, 'Maximum', obj.master.obj_fileManager.numImages);
            set(handles.hprogressbarhandleFindCells, 'Value', 1);
            
            fileManagerHandles = guidata(obj.master.obj_fileManager.gui_fileManager);
            predictionMode = getCurrentPopupString(fileManagerHandles.hpopupPredictionMode);
            if(strcmp(predictionMode, 'Prediction'))
                load(fullfile('Prediction', sprintf('wellsss_s%d.mat', obj.master.obj_fileManager.selectedPosition)));
            end

            for i=1:obj.master.obj_fileManager.numImages
                timepoint = obj.master.obj_fileManager.currentImageTimepoints(i);
                set(handles.hprogressbarhandleFindCells, 'Value', i);
                referenceImage = obj.master.obj_imageViewer.imageBuffer(:,:,i);
                                
                % Preprocess and find local maxima
                switch predictionMode
                    case 'Intensity'
                        localMaxima = getImageMaxima_Intensity(referenceImage, blurRadius);
                    case 'Shape'
                        localMaxima = getImageMaxima_Shape(referenceImage, blurRadius);
                    case 'Prediction'
                        localMaxima = fliplr(round(wellsss{timepoint}(:,1:2))* obj.imageResizeFactor);
                end
                obj.centroidsLocalMaxima.insertCentroids(timepoint, localMaxima);
            end
            set(handles.hprogressbarhandleFindCells, 'Value', 0);
        end
        
        function replaceCellTimepoints(obj, sourceCell, targetCell, timepoints)
            for i=timepoints
                obj.centroidsTracks.setCentroid(i, targetCell, obj.centroidsTracks.getCentroid(i, sourceCell), obj.centroidsTracks.getValue(i, sourceCell));
                obj.centroidsDivisions.setCentroid(i, targetCell, obj.centroidsDivisions.getCentroid(i, sourceCell), obj.centroidsDivisions.getValue(i, sourceCell));
                obj.centroidsDeath.setCentroid(i, targetCell, obj.centroidsDeath.getCentroid(i, sourceCell), obj.centroidsDivisions.getValue(i, sourceCell));
            end
        end
        
        function predictedCentroid = predictNextCell(obj, previousFrame, predictionMode)
            currentFrame = obj.master.obj_imageViewer.currentFrame;
            currentTimepoint = obj.master.obj_imageViewer.currentTimepoint;
            selectedCell = obj.master.obj_imageViewer.selectedCell;
            searchRadius = obj.getDistanceRadius;
            centroids = obj.master.obj_imageViewer.obj_cellTracker.centroidsTracks.getCellTrack(selectedCell);
            centroids = centroids(obj.master.obj_fileManager.currentImageTimepoints,:);
            if(centroids(previousFrame,1) == 0)
                predictedCentroid = [0,0];
                return;
            end
        end
        
        function setPlayWhileTracking(obj, value)
            obj.playWhileTracking = value;
        end
        
        function trackSister(obj)
            newCell = obj.centroidsTracks.getAvailableCellId;
            obj.centroidsTracks.setCentroid(obj.master.obj_imageViewer.currentTimepoint, newCell, obj.centroidsTracks.getCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell), 1);
            obj.centroidsDivisions.setCentroid(obj.master.obj_imageViewer.currentTimepoint, newCell, obj.centroidsTracks.getCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell), 1);
           
            obj.master.obj_imageViewer.setSelectedCell(newCell);
            handles = guidata(obj.gui_cellTracker);
            set(handles.htogglebuttonTrackingMode, 'Value', 1);
            obj.isTracking = 1;
            obj.master.obj_imageViewer.obj_cellTracker.firstClick = 0;
            obj.master.obj_imageViewer.nextFrame;
            obj.master.obj_imageViewer.setImage;
            obj.setAvailableCells;
        end
                
        %% Delete function
        function delete(obj)
            % Ask if the user wants to save the annotation
            delete(obj.gui_cellTracker);
        end
    end
end