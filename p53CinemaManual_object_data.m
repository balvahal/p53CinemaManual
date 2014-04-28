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
    events
        
    end
    methods
        function obj = p53CinemaManual_object_data()
            
        end
        function obj = importCentroidsTracks(obj,centroidsTracks)
            firsttimepoint = centroidsTracks.singleCells(1).point;
            firsttimepoint = sum(firsttimepoint,2);
            number_of_cells = sum(firsttimepoint==0);
            for i = 1:number_of_cells
                tempArray = zeros(length(centroidsTracks.singleCells),2);
            for j = 1:length(centroidsTracks.singleCells)
                tempPoints = centroidsTracks.singleCells(j).point;
                tempArray(j,:) = tempPoints(i,:);
            end
            tempMap = containers.Map({num2str(i)},{tempArray});
            obj.manualTrackingData = [obj.manualTrackingData;tempMap];
            end
        end
    end
end