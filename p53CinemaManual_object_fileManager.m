%%
%
classdef p53CinemaManual_object_fileManager < handle
    properties
        gui_fileManager;
        master;
        database;
        selectedGroup;
        selectedPosition;
        selectedChannel;
        currentImageFilenames;
        currentImageTimepoints;
        maxTimepoint;
        
        preallocateMode;
        preprocessMode;
    end
    events
        
    end
    methods
        %% Constructor
        function obj = p53CinemaManual_object_fileManager(master)
            obj.gui_fileManager = p53CinemaManual_gui_fileManager(master);
            obj.master = master;
        end
        
        %% Set variables
        function setDatabase(obj, database)
            obj.database = database;
        end
        function setSelectedGroup(obj, selectedGroup)
            obj.selectedGroup = selectedGroup;
        end
        function setSelectedPosition(obj, selectedPosition)
            obj.selectedPosition = selectedPosition;
        end
        function setSelectedChannel(obj, selectedChannel)
            obj.selectedChannel = selectedChannel;
        end
        function setPreprocessMode(obj, value)
            obj.preprocessMode = value;
        end
        function setPreallocateMode(obj, value)
            obj.preallocateMode = value;
        end
        
        %% Generate image sequence
        function generateImageSequence(obj)
            relevantImageIndex = strcmp(obj.database.group_label, obj.selectedGroup) & strcmp(obj.database.channel_name, obj.selectedChannel) & obj.database.position_number == obj.selectedPosition;
            obj.currentImageFilenames = obj.database.filename(relevantImageIndex);
            obj.currentImageTimepoints = obj.database.timepoint(relevantImageIndex);
            [obj.currentImageTimepoints, orderIndex] = sort(obj.currentImageTimepoints);
            obj.currentImageFilenames = obj.currentImageFilenames(orderIndex);
            obj.maxTimepoint = max(obj.database.timepoint(strcmp(obj.database.group_label, obj.selectedGroup) & obj.database.position_number == obj.selectedPosition));
        end
        
        %% Delete function
        function delete(obj)
            delete(obj.gui_fileManager);
        end
    end
end