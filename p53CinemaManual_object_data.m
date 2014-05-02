%% p53Cinema Data in source object
% The data captured in a set of images is used to create many data features
% including the signal traces of a cell, spatial tracking information, and
% in silico temporal based synchronization. A source object will contain
% all the data extracted from a set of images in format that is most
% convenient with the method used to generate the data. From the source
% object, derivative data organization or presentation schemes can be
% derived that make the data convenient to interact with.
classdef p53CinemaManual_object_data < handle
    properties
        cellIDs = cell(0,0);
        stagePositionOrigin = containers.Map;
        manualTrackingData = containers.Map;
        motherLineage = containers.Map;
        timepoints = containers.Map;
        cellPerspective = containers.Map;
        cellPerspectivePrototype;
        cellkeys;
        cellvalues;
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_object_data()
            obj.cellkeys{1} = 'stagePositionNumber';    obj.cellvalues{1} = 0;
            obj.cellkeys{2} = 'manualTrackingData';     obj.cellvalues{2} = [0,0];
            obj.cellkeys{3} = 'motherLineage';          obj.cellvalues{3} = '';
            obj.cellkeys{4} = 'timepoints';             obj.cellvalues{4} = 0;
            obj.cellPerspectivePrototype = containers.Map(obj.cellkeys,obj.cellvalues);
            
        end
        function obj = importCentroidsTracks(obj,centroidsTracks)
            obj = p53CinemaManual_method_data_importCentroidsTracks(obj,centroidsTracks);
        end
    end
end