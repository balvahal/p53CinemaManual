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
            obj.centroidsLocalMaxima = CentroidTimeseries(master.obj_fileManager.maxTimepoint, 10000);
            obj.centroidsTracks = CentroidTimeseries(master.obj_fileManager.maxTimepoint, 10000);
            obj.centroidsDivisions = CentroidTimeseries(master.obj_fileManager.maxTimepoint, 10000);
            obj.centroidsDeath = CentroidTimeseries(master.obj_fileManager.maxTimepoint, 10000);
            obj.master = master;
            
            obj.isTracking = 0;
            obj.isPaused = 0;
            obj.firstClick = 1;
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
                obj.centroidsDivisions.setCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell, centroid, 0);
            end
        end
        
        function [] = setDeathEvent(obj)
            centroid = obj.centroidsTracks.getCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell);
            if(centroid(1) > 0)
                obj.centroidsDeath.setCentroid(obj.master.obj_imageViewer.currentTimepoint, obj.master.obj_imageViewer.selectedCell, centroid, 0);
            end
        end
        
        function triggerTracking(obj, altEvent)
            p53CinemaManual_method_cellTracker_triggerTracking(obj,altEvent);
        end
                
        %% Delete function
        function delete(obj)
            % Ask if the user wants to save the annotation
            delete(obj.gui_cellTracker);
        end
    end
end