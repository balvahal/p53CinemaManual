%% p53Cinema Data in source object
% The data captured in a set of images is used to create many data features
% including the signal traces of a cell, spatial tracking information, and
% in silico temporal based synchronization. A source object will contain
% all the data extracted from a set of images in format that is most
% convenient with the method used to generate the data. From the source
% object, derivative data organization or presentation schemes can be
% derived that make the data convenient to interact with.
classdef p53CinemaManual_object_master < handle
    properties
        data;
        obj_imageViewer;
        obj_fileManager;
        image_width;
        image_height;
        image_widthChar;
        image_heightChar;
    end
    properties (SetAccess = private)
        ppChar; % the guis are all in character units, but the images are defined by pixels.
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_object_master()
            %%
            % get pixels to character info
            myunits = get(0,'units');
            set(0,'units','pixels');
            Pix_SS = get(0,'screensize');
            set(0,'units','characters');
            Char_SS = get(0,'screensize');
            obj.ppChar = Pix_SS./Char_SS;
            obj.ppChar = obj.ppChar([3,4]);
            set(0,'units',myunits);
            
            %% Load settings
            %
            obj.image_width = 1008;
            obj.image_height = 768;
            obj.image_widthChar = obj.image_width/obj.ppChar(1);
            obj.image_heightChar = obj.image_height/obj.ppChar(2);
            %% Start all guis
            %
            
            obj.obj_fileManager = p53CinemaManual_object_fileManager(obj);
<<<<<<< HEAD
=======
        end
        function initializeImageViewer(obj)
            if(~isempty(obj.obj_imageViewer))
                obj.obj_imageViewer.delete;
            end
            obj.obj_imageViewer = p53CinemaManual_object_imageViewer(obj);
>>>>>>> d61069ddbd853d0e04cb9c815cee66cb505f18d7
        end
        function delete(obj)
            delete(obj.obj_fileManager);
            delete(obj.obj_imageViewer);
        end
    end
end