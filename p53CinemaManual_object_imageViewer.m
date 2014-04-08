%% p53Cinema Data in source object
% The data captured in a set of images is used to create many data features
% including the signal traces of a cell, spatial tracking information, and
% in silico temporal based synchronization. A source object will contain
% all the data extracted from a set of images in format that is most
% convenient with the method used to generate the data. From the source
% object, derivative data organization or presentation schemes can be
% derived that make the data convenient to interact with.
classdef p53CinemaManual_object_imageViewer < handle
    properties
        gui_imageViewer;
        pixelxy;
    end
    properties (SetObservable)
        
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_object_imageViewer()
            obj.gui_imageViewer = p53CinemaManual_gui_imageViewer(obj);
        end
        
        function out = getPixelxy(obj)
            myCurrentPoint = get(obj.gui_imageViewer,'CurrentPoint');
            handles = guidata(obj.gui_imageViewer);
            axesOrigin = get(handles.SourceImage,'Position');
            myRelativePoint = myCurrentPoint - axesOrigin(1:2);
            if any(myRelativePoint<0)
                obj.pixelxy = [];
            else
                x = round(myRelativePoint(1)*handles.ppChar(3));
                y = round(myRelativePoint(2)*handles.ppChar(4));
                obj.pixelxy = [x,y];
            end
            out = obj.pixelxy;
        end
    end
end