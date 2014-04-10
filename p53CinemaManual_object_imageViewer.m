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
        master;
        isMyButtonDown = false;
        imageSize;
        numberOfImages;
        imageList;
        imageBuffer;
        imageOrigin;
        displaySize;
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_object_imageViewer(master,myimageSize,mynumberOfImages,myimageList)
            obj.master = master;
            obj.imageSize = myimageSize;
            obj.numberOfImages = mynumberOfImages;
            %% Preload images
            %
            %% Launch the gui
            %
            obj.gui_imageViewer = p53CinemaManual_gui_imageViewer(master);
        end
        
        function out = getPixelxy(obj)
            myCurrentPoint = get(obj.gui_imageViewer,'CurrentPoint');
            handles = guidata(obj.gui_imageViewer);
            axesOrigin = get(handles.axesSourceImage,'Position');
            myRelativePoint = myCurrentPoint - axesOrigin(1:2);
            if any(myRelativePoint<0) || ...
                    myRelativePoint(1) > obj.master.image_widthChar || ...
                    myRelativePoint(2) > obj.master.image_heightChar
                obj.pixelxy = [];
            else
                x = round(myRelativePoint(1)*obj.master.ppChar(1));
                y = round(myRelativePoint(2)*obj.master.ppChar(2));
                obj.pixelxy = [x,y];
            end
            out = obj.pixelxy;
        end
        
        function delete(obj)
            delete(obj.gui_imageViewer);
        end
    end
end