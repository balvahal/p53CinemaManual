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
        
        function annotationType = cellFateEvent(obj)
            handles = guidata(obj.gui_cellTracker);
            eventType = get(handles.u0, 'Value');
            if(eventType)
                annotationType = 'Division';
            else
                annotationType = 'Death';
            end
        end
        
        function triggerTracking(obj, altEvent)
            p53CinemaManual_method_cellTracker_triggerTracking(obj,altEvent);
            %%
%             if obj.master.debugmode
%                 currentPoint = obj.master.obj_imageViewer.getPixelxy;
%                 if ~isempty(currentPoint)
%                     mystr = sprintf('x = %d\ty = %d',currentPoint(1),currentPoint(2));
%                     disp(mystr);
%                 else
%                     mystr = sprintf('OUTSIDE AXES!!!');
%                     disp(mystr);
%                 end
%             end
%             if(~obj.isTracking)
%                 return;
%             end
%             
%             currentPoint = obj.master.obj_imageViewer.getPixelxy;
%             currentTimepoint = obj.master.obj_imageViewer.currentTimepoint;
%             if(isempty(currentPoint))
%                 return;
%             end
%             % If the dataset has been preprocessed, perform tracking under
%             % "magnet mode"
%             if(obj.master.obj_fileManager.preprocessMode)
%                 lookupRadius = obj.getDistanceRadius;
%                 queryCentroid = obj.centroidsLocalMaxima.getClosestCentroid(currentTimepoint, fliplr(currentPoint), lookupRadius);
%             else
%                 queryCentroid = fliplr(currentPoint);
%             end
%             % If this is the first time the user clicks after starting a new
%             % track, define the selected cell
%             if(obj.firstClick)
%                 lookupRadius = obj.getDistanceRadius / 6; % 6 was chosen empircally when comparing a 30 pixel radius search area with a 5 pixel radius selection area
%                 [cellCentroid1, cell_id1] = obj.centroidsTracks.getClosestCentroid(currentTimepoint, queryCentroid, lookupRadius);
%                 [cellCentroid2, cell_id2] = obj.centroidsTracks.getClosestCentroid(currentTimepoint, fliplr(currentPoint), lookupRadius);
%                 if(~isempty(cell_id2))
%                     obj.master.obj_imageViewer.setSelectedCell(cell_id2);
%                     queryCentroid = cellCentroid2;
%                 elseif(~isempty(cell_id1))
%                     obj.master.obj_imageViewer.setSelectedCell(cell_id1);
%                     queryCentroid = cellCentroid1;
%                 else
%                     obj.master.obj_imageViewer.setSelectedCell(obj.centroidsTracks.getAvailableCellId);
%                 end
%                 obj.firstClick = 0;
%             end
%             
%             %% Set the centroids in selected cell and time
%             selectedCell = obj.master.obj_imageViewer.selectedCell;
%             obj.centroidsTracks.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
%             % Move centroid if there was one in division or death events
%             if(obj.centroidsDivisions.getValue(currentTimepoint, selectedCell))
%                 obj.centroidsDivisions.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
%             end
%             if(obj.centroidsDeath.getValue(currentTimepoint, selectedCell))
%                 obj.centroidsDeath.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
%             end
%             
%             obj.setAvailableCells;
%             
%             selectionType = altEvent;
%             if(strcmp(selectionType, 'alt'))
%                 annotationType = obj.cellFateEvent;
%                 if(strcmp(annotationType, 'Division'))
%                     obj.centroidsDivisions.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
%                 end
%                 if(strcmp(annotationType, 'Death'))
%                     obj.centroidsDeath.setCentroid(currentTimepoint, selectedCell, queryCentroid, 1);
%                 end
%             end
%             
%             obj.master.obj_imageViewer.setImage;
%             drawnow;
%             frameSkip = obj.getFrameSkip;
%             obj.master.obj_imageViewer.nextFrame;
        end
                
        %% Delete function
        function delete(obj)
            % Ask if the user wants to save the annotation
            delete(obj.gui_cellTracker);
        end
    end
end