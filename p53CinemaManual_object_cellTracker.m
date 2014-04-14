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
        
        selectedCell;
        
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
        end
        
        %% Delete function
        function delete(obj)
            % Ask if the user wants to save the annotation
            delete(obj.gui_cellTracker);
        end
    end
end