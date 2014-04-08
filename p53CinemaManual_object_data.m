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
        manualTrackingData = containers.Map;
        motherLineage = containers.Map;
    end
    properties (SetObservable)
        
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_object_data()
            
        end
    end
end