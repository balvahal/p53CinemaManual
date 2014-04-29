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
        cellPerspective;
        cellProtoContainer;
        cellkeys;
        cellvalues;
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_object_data()
            cellkeys{1} = 'stagePositionOrigin';    cellvalues{1} = 0;
            cellkeys{2} = 'manualTrackingData';     cellvalues{2} = [0,0];
            cellkeys{3} = 'motherLineage';          cellvalues{3} = '';
            cellkeys{4} = 'timepoints';             cellvalues{4} = 0;
            cellProtoContainer = containers.Map(cellkeys,cellvalues);
            
        end
        function obj = importCentroidsTracks(obj,centroidsTracks)
            obj = p53CinemaManual_method_data_importCentroidsTracks(obj,centroidsTracks);
        end
    end
end