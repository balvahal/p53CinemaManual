%%
%
classdef p53Cinema_singleCellAnnotation_object_featureTracker < handle
    properties
        gui_featureTracker;
        master;
        
        distanceRadius;
        addMode;
        deleteMode;
        
        centroidsLocalMaxima;
        centroidsFeatures;
    end
    events
        
    end
    methods
        %% Constructor
        function obj = p53Cinema_singleCellAnnotation_object_featureTracker(master)
            obj.gui_featureTracker = p53Cinema_singleCellAnnotation_gui_featureTracker(master);
            obj.centroidsLocalMaxima = CentroidTimeseries(master.obj_fileManager.maxTimepoint, 10000);
            obj.centroidsFeatures = CentroidTimeseries(master.obj_fileManager.maxTimepoint, 1000);
            
            obj.master = master;
        end
        
        function setAvailableCells(obj)
            availableCells = obj.centroidsFeatures.getTrackedCellIds;
            selectedCell = obj.master.obj_imageViewer.selectedCell;
            handles = guidata(obj.gui_featureTracker);
            
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
        
        function setAddMode(obj)
            handles = guidata(obj.gui_featureTracker);
            viewerHandles = guidata(obj.master.obj_imageViewer.gui_imageViewer);
            
            set(handles.htogglebuttonDeletionMode, 'Value', 0);
            obj.deleteMode = 0;
            
            if(obj.addMode)
                set(viewerHandles.closestCellPatch, 'MarkerEdgeColor',[0.9,0.75,0],'MarkerFaceColor',[255 215 0]/255);
                set(handles.htogglebuttonAnnotationMode, 'Value', 0);
                obj.addMode = 0;
            else
                set(viewerHandles.closestCellPatch, 'MarkerEdgeColor',[0,0.75,1],'MarkerFaceColor',[0,0.25,1]);
                set(handles.htogglebuttonAnnotationMode, 'Value', 1);
                obj.addMode = 1;
            end            
        end
                
        function setDeleteMode(obj)
            handles = guidata(obj.gui_featureTracker);
            viewerHandles = guidata(obj.master.obj_imageViewer.gui_imageViewer);
            
            set(handles.htogglebuttonAnnotationMode, 'Value', 0);
            obj.addMode = 0;
            
            if(obj.deleteMode)
                set(viewerHandles.closestCellPatch, 'MarkerEdgeColor',[0.9,0.75,0],'MarkerFaceColor',[255 215 0]/255);
                set(handles.htogglebuttonDeletionMode, 'Value', 0);
                obj.deleteMode = 0;
            else
                set(viewerHandles.closestCellPatch, 'MarkerEdgeColor',[1,0.75,0],'MarkerFaceColor',[1,0,0]);
                set(handles.htogglebuttonDeletionMode, 'Value', 1);
                obj.deleteMode = 1;
            end
        end
                
        function radius = getDistanceRadius(obj)
            handles = guidata(obj.gui_featureTracker);
            radius = str2double(get(handles.heditDistanceRadius, 'String'));
        end
        
        function editAnnotation(obj, selectionType)
            currentTimepoint = obj.master.obj_imageViewer.currentTimepoint;
            currentPoint = fliplr(obj.master.obj_imageViewer.pixelxy);
            lookupRadius = obj.getDistanceRadius;
            
            % If the user right clicked, add the centroid to both the
            % localMaxima database and to the current features database
            if(strcmp(selectionType, 'alt'))
                obj.centroidsLocalMaxima.setCentroid(currentTimepoint, obj.centroidsLocalMaxima.getAvailableCellId, currentPoint, 0);
                obj.centroidsFeatures.setCentroid(currentTimepoint, obj.centroidsFeatures.getAvailableCellId, currentPoint, 0);
            else
                [closestCentroidLocalMaxima, ~, distanceLocalMaxima] = obj.centroidsLocalMaxima.getClosestCentroid(currentTimepoint, currentPoint, lookupRadius);
                [~, cellIdFeatures, distanceFeatures] = obj.centroidsFeatures.getClosestCentroid(currentTimepoint, currentPoint, lookupRadius);
                
                if(distanceLocalMaxima < distanceFeatures)
                    if(obj.addMode)
                        selectedCell = obj.centroidsFeatures.getAvailableCellId;
                        obj.centroidsFeatures.setCentroid(currentTimepoint, selectedCell, closestCentroidLocalMaxima, 0);
                        obj.master.obj_imageViewer.setSelectedCell(selectedCell);
                    end
                else
                    obj.master.obj_imageViewer.setSelectedCell(cellIdFeatures);
                    if(obj.deleteMode)
                        obj.centroidsFeatures.setCentroid(currentTimepoint, cellIdFeatures, [0,0], 0);
                        obj.master.obj_imageViewer.setSelectedCell(0);
                    end
                end
                
            end
            % Refresh image
            obj.master.obj_imageViewer.setImage;
            
        end
                        
        %% Delete function
        function delete(obj)
            % Ask if the user wants to save the annotation
            delete(obj.gui_featureTracker);
        end
    end
end