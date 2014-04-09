%%
%
classdef p53CinemaManual_object_fileManager < handle
    properties
        gui_fileManager;
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_object_imageViewer(master)
            obj.gui_fileManager = p53CinemaManual_gui_fileManager(master);
        end
                
        function delete(obj)
            delete(obj.gui_fileManager);
        end
    end
end