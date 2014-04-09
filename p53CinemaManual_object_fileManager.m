%%
%
classdef p53CinemaManual_object_fileManager < handle
    properties
        gui_fileManager;
        master;
        database;
        selectedGroup;
        selectedPosition;
        selecteChannel;
    end
    events
        
    end
    methods
        function obj = p53CinemaManual_object_fileManager(master)
            obj.gui_fileManager = p53CinemaManual_gui_fileManager(master);
        end
        
        function out = setDatabase(obj, database)
            obj.database = database;
        end
                
        function delete(obj)
            delete(obj.gui_fileManager);
        end
    end
end