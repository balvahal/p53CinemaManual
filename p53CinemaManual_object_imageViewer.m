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
        imageList;
        imageBuffer;
        imageOrigin;
        displaySize;
        image_width;
        image_height;
        image_widthChar;
        image_heightChar;
        currentFrame = 1;
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_object_imageViewer(master)
            obj.master = master;
            %% get image info from first image
               %
            myinfo = imfinfo(fullfile(master.obj_fileManager.rawdatapath,master.obj_fileManager.currentImageFilenames{1}));
            obj.image_width = myinfo.Width;
            obj.image_height = myinfo.Height;
            obj.image_widthChar = obj.image_width/master.ppChar(1);
            obj.image_heightChar = obj.image_height/master.ppChar(2);
            %% Preload images
            %
        end
        
        function out = getPixelxy(obj)
            myCurrentPoint = get(obj.gui_imageViewer,'CurrentPoint');
            handles = guidata(obj.gui_imageViewer);
            axesOrigin = get(handles.axesSourceImage,'Position');
            myRelativePoint = myCurrentPoint - axesOrigin(1:2);
            if any(myRelativePoint<0) || ...
                    myRelativePoint(1) > obj.image_widthChar || ...
                    myRelativePoint(2) > obj.image_heightChar
                obj.pixelxy = [];
            else
                x = round(myRelativePoint(1)*obj.master.ppChar(1));
                y = round(myRelativePoint(2)*obj.master.ppChar(2));
                obj.pixelxy = [x,y];
            end
            out = obj.pixelxy;
        end
        function obj = launchImageViewer(obj)
            %% Launch the gui
            %
            obj.gui_imageViewer = p53CinemaManual_gui_imageViewer(obj.master);
        end
        function delete(obj)
            delete(obj.gui_imageViewer);
        end
    end
end