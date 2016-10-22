%%
%
classdef p53Cinema_singleCellAnnotation_object_fileManager < handle
    properties
        gui_fileManager;
        master;
        
        database;
        mainpath;
        databaseFilename;
        rawdatapath;
        
        selectedGroup;
        selectedPosition;
        selectedChannel;
        selectedCell;
        
        currentImageFilename;
        currentImageTimepoints;
        numImages;
        maxTimepoint;
        timepointRange;
        
        preallocateMode;
        preprocessMode;
        predictionMode;
        
        imageResizeFactor;
        cellSize;
        maxHeight;
    end
    events
        
    end
    methods
        %% Constructor
        function obj = p53Cinema_singleCellAnnotation_object_fileManager(master)
            obj.gui_fileManager = p53Cinema_singleCellAnnotation_gui_fileManager(master);
            obj.master = master;
        end
        
        %% Set variables
        function setDatabase(obj, database)
            obj.database = database;
            obj.master.data.database = database;
        end
        function setRawDataPath(obj, rawdatapath)
            obj.rawdatapath = rawdatapath;
            obj.master.data.imagepath = rawdatapath;
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
        function setSelectedCell(obj, selectedCell)
            obj.selectedCell = selectedCell;
        end
        function setPreprocessMode(obj, value)
            obj.preprocessMode = value;
        end
        function setPreallocateMode(obj, value)
            obj.preallocateMode = value;
        end
        function setImageResize(obj, value)
            obj.imageResizeFactor = value;
        end
        function setCellSize(obj, value)
            obj.cellSize = value;
        end
        function setMaxHeight(obj, value)
            obj.maxHeight = value;
        end
        function setMaxTimepoint(obj, value)
            obj.maxTimepoint = value;
        end
        function setPredictionMode(obj, value)
            obj.predictionMode = value;
        end
        
        function setProgressBar(obj, value, maxValue, message)
            handles = guidata(obj.master.obj_fileManager.gui_fileManager);
            set(handles.hprogressbarhandleLoadingBar, 'Maximum', maxValue);
            set(handles.hprogressbarhandleLoadingBar, 'Value', value);
            set(handles.htextLoadingBar, 'String', message);
        end
        
        function setTimepointRange(obj, from, to, by)
            from = str2double(from);
            to = str2double(to);
            by = str2double(by);
            from = floor(max(1, from));
            to = floor(min(obj.maxTimepoint, to));
            by = ceil(by);
            obj.timepointRange = [from, to, by];
        end
        
        %% Generate image sequence
        function generateImageSequence(obj)
            if(~iscell(obj.database.channel_name))
                channel_filter = obj.database.channel_name == str2double(obj.selectedChannel);
            else
                channel_filter = strcmp(obj.database.channel_name, obj.selectedChannel);
            end
            relevantImageIndex = strcmp(obj.database.group_label, obj.selectedGroup) & channel_filter & obj.database.position_number == obj.selectedPosition & obj.database.cell_id == obj.selectedCell;
            
            obj.currentImageFilename = obj.database.filename{relevantImageIndex};
            obj.currentImageTimepoints = obj.timepointRange(1):obj.timepointRange(3):obj.timepointRange(2);
            obj.numImages = length(obj.currentImageTimepoints);
        end
        
        function filename = getFilename(obj, position, channel, timepoint)
            filename = getDatabaseFile(obj.database, channel, position, timepoint);
        end
        
        %% Delete function
        function delete(obj)
            delete(obj.gui_fileManager);
        end
    end
end