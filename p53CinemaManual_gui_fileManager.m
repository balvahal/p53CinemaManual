%% p53CinemaManual_gui_fileManager
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_fileManager(master)
%% Create the figure
%
set(0,'units','characters');
Char_SS = get(0,'screensize');
fwidth = 450/master.ppChar(1);
fheight = 470/master.ppChar(2);
fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Renderer','OpenGL','Position',[fx fy fwidth fheight],...
    'KeyPressFcn',{@fKeyPressFcn});
%% Construct the components
hwidth = 120/master.ppChar(1);
hheight = 20/master.ppChar(2);
hmargin = 25/master.ppChar(2);
hmargin_short = 7/master.ppChar(2);
hx = 20/master.ppChar(1);
hy = fheight - (hmargin + hheight);

%% Layout: file path information
htextDatabasePath = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Database file','Position',[hx, hy, hwidth, hheight],...
    'Enable', 'inactive','parent',f);
heditDatabasePath = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'parent',f);
hbuttonDatabasePath = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Browse','Position',[hx + 2*hmargin + 2.5*hwidth, hy, hwidth * 0.75, hheight],...
    'Callback',{@pushbuttonDatabasePath_Callback},'parent',f);

hy = hy - hheight - hmargin_short;
htextRawDataPath = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Raw data path','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditRawDataPath = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Enable', 'off', 'parent',f);

hy = hy - hheight - hmargin_short;
htextSegmentDataPath = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Segment data path','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditSegmentDataPath = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Enable', 'off', 'parent',f);

%% Layout: image sequence information (group, position and channel)
hy = hy - hheight - hmargin;
htextGroupLabel = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Group label','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hpopupGroupLabel = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Select group','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Callback',{@popupGroupLabel_Callback},'Enable', 'off', 'parent',f);

hy = hy - hheight - hmargin_short;
htextStagePosition = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Stage position','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hpopupStagePosition = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Select position','Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Callback',{@popupStagePosition_Callback},'Enable', 'off', 'parent',f);

hy = hy - hheight - hmargin_short;
htextPimaryChannel = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Primary channel','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hpopupPimaryChannel = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Select channel','Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Enable', 'off', 'parent',f);
hcheckboxPrimaryBackground = uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Substract background','Value',1,'Position',[hx + 2*hmargin + 2*hwidth, hy, hwidth*1.75, hheight],...
    'parent',f);

hy = hy - hheight - hmargin_short;
htextMaximaChannel = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Maxima channel','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hpopupMaximaChannel = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Select channel','Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Enable', 'off', 'parent',f);

%% Layout: Loading range
hy = hy - hheight - hmargin;
htextFromTimepoint = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Image range','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hy = hy - hheight - hmargin_short;
htextFromTimepoint = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','From','Position',[hx, hy, hwidth /3, hheight],...
    'parent',f);
heditFromTimepoint = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','1','Position',[hx + hmargin + hwidth/3, hy, hwidth /3, hheight],...
    'parent',f);
htextToTimepoint = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','To','Position',[hx + hmargin*2 + 2*hwidth/3, hy, hwidth /3, hheight],...
    'parent',f);
heditToTimepoint = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Inf','Position',[hx + hmargin*3 + 3*hwidth/3, hy, hwidth /3, hheight],...
    'parent',f);
htextByTimepoint = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','By','Position',[hx + hmargin*4 + 4*hwidth/3, hy, hwidth /3, hheight],...
    'parent',f);
heditByTimepoint = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','1','Position',[hx + hmargin*5 + 5*hwidth/3, hy, hwidth /3, hheight],...
    'parent',f);


%% Layout: Data loading options
hy = hy - hheight - hmargin;
htextImageResize = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Resize factor','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditImageResize = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','1.0','Position',[hx + hmargin + hwidth, hy, hwidth * 0.5, hheight],...
    'parent',f);
hcheckboxPreallocate = uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Preallocate','Position',[hx + hmargin + 1.75*hwidth, hy, hwidth, hheight],...
    'Callback',{@checkboxPreallocate_Callback},'Value',0,'parent',f);
hcheckboxPreprocess = uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Preprocess','Position',[hx + hmargin + 1.75*hwidth, hy - hheight, hwidth, hheight],...
    'Callback',{@checkboxPreprocess_Callback},'Value',0,'parent',f);
hy = hy - hheight - hmargin_short;
htextCellSize = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Cell size','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditCellSize = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','20','Position',[hx + hmargin + hwidth, hy, hwidth * 0.5, hheight],...
    'parent',f);
hy = hy - hheight - hmargin_short;
htextMaxHeight = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Max height','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditMaxHeight = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','1200','Position',[hx + hmargin + hwidth, hy, hwidth * 0.5, hheight],...
    'parent',f);


%% Layout: Load button
hy = hy - hheight - hmargin;
[hprogressbarhandleLoadingBar, hprogressbarLoadingBar] = javacomponent('javax.swing.JProgressBar');
set(hprogressbarLoadingBar, 'Units', get(f, 'Units'), 'Position', [hx, hy, hwidth, hheight], 'Parent', f);
hpushbuttonLoadData = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Load','Position',[hx + hmargin + hwidth, hy, hwidth * 0.75, hheight],...
    'Callback',{@pushbuttonLoadData_Callback},'parent',f);

hy = hy - hheight;
htextLoadingBar = uicontrol('Style','text','Units','characters',...
    'FontSize',8,'FontName','Arial','HorizontalAlignment','left',...
    'String','Loading status','Position',[hx, hy, hwidth, hheight],...
    'parent',f);

handles.hpopupPimaryChannel = hpopupPimaryChannel;
handles.hcheckboxPrimaryBackground = hcheckboxPrimaryBackground;
handles.hprogressbarLoadingBar = hprogressbarLoadingBar;
handles.hprogressbarhandleLoadingBar = hprogressbarhandleLoadingBar;
handles.htextLoadingBar = htextLoadingBar;
guidata(f,handles);

%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
%% Browse database file
%
    function pushbuttonDatabasePath_Callback(~,~)
        [databaseFile, sourcePath] = uigetfile('./*.txt');
        database = readtable(fullfile(sourcePath, databaseFile), 'Delimiter', '\t');
        if(~iscell(database.group_label))
            database.group_label = cellfun(@num2str, num2cell(database.group_label), 'UniformOutput', 0);
        end
        if(~iscell(database.channel_name))
            database.channel_name = cellfun(@num2str, num2cell(database.position_number), 'UniformOutput', 0);
        end
        
        set(heditDatabasePath, 'String', fullfile(sourcePath, databaseFile));
        set(heditRawDataPath, 'String', fullfile(sourcePath, 'RAW_DATA'));
        set(heditSegmentDataPath, 'String', fullfile(sourcePath, 'SEGMENT_DATA'));
        master.obj_fileManager.setDatabase(database);
        master.obj_fileManager.setRawDataPath(get(heditRawDataPath, 'String'));
        master.obj_fileManager.mainpath = sourcePath;
        master.obj_fileManager.databaseFilename = databaseFile;
        
        availableGroups = unique(database.group_label);
        set(hpopupGroupLabel, 'String', availableGroups);
        set(hpopupGroupLabel, 'Enable', 'on');
        master.obj_fileManager.setSelectedGroup(getCurrentPopupString(hpopupGroupLabel));
        
        populatePositionChannel
        
    end

    function popupGroupLabel_Callback(~,~)
        populatePositionChannel;
    end

    function popupStagePosition_Callback(~,~)
        populateChannel;
    end

    function pushbuttonLoadData_Callback(~,~)
        % Define the selected group, position and channel in the file
        % manager object
        master.obj_fileManager.setSelectedGroup(getCurrentPopupString(hpopupGroupLabel));
        master.obj_fileManager.setSelectedPosition(str2double(getCurrentPopupString(hpopupStagePosition)));
        master.obj_fileManager.setSelectedChannel(getCurrentPopupString(hpopupPimaryChannel));
        master.obj_fileManager.setMaximaChannel(getCurrentPopupString(hpopupMaximaChannel));
        % Generate a sequence of images representing the current data to
        % visualize, save the timepoints each image corresponds to and sort
        % the filenames by timepoint.
        master.obj_fileManager.setTimepointRange(get(heditFromTimepoint,'String'), get(heditToTimepoint,'String'), get(heditByTimepoint,'String'));
        master.obj_fileManager.generateImageSequence;
        master.obj_fileManager.setPreprocessMode(get(hcheckboxPreprocess,'Value'));
        master.obj_fileManager.setPreallocateMode(get(hcheckboxPreallocate,'Value'));
        master.obj_fileManager.setImageResize(str2double(get(heditImageResize,'String')));
        master.obj_fileManager.setCellSize(str2double(get(heditCellSize,'String')));
        master.obj_fileManager.setMaxHeight(str2double(get(heditMaxHeight,'String')));
        % Trigger image set-up in the viewer object
        master.initializeImageViewer;
    end

    function checkboxPreallocate_Callback(~,~)
        if(~get(hcheckboxPreallocate, 'Value'))
            set(hcheckboxPreprocess, 'Value', 0);
        end
    end

    function checkboxPreprocess_Callback(~,~)
        if(get(hcheckboxPreprocess, 'Value'))
            set(hcheckboxPreallocate, 'Value', 1);
        end
    end
%% Populate position and channel
%
    function populatePositionChannel
        database = master.obj_fileManager.database;
        availablePositions = unique(database.position_number(strcmp(database.group_label, getCurrentPopupString(hpopupGroupLabel))));
        set(hpopupStagePosition, 'Value', 1);
        set(hpopupStagePosition, 'String', num2str(availablePositions));
        set(hpopupStagePosition, 'Enable', 'on');
        
        populateChannel;
    end

    function populateChannel
        database = master.obj_fileManager.database;
        
        availableChannels = unique( ...
            database.channel_name(strcmp(database.group_label, getCurrentPopupString(hpopupGroupLabel)) & ...
            database.position_number == str2double(getCurrentPopupString(hpopupStagePosition))));
        % When the position is changed, if the previously selected channel
        % is available, it will remain selected. Otherwise, it will default
        % to the first available option.
        previousValue = getCurrentPopupString(hpopupPimaryChannel);
        set(hpopupPimaryChannel, 'Value', 1);
        set(hpopupPimaryChannel, 'String', availableChannels);
        set(hpopupPimaryChannel, 'Value', getPopupIndex(hpopupPimaryChannel, previousValue));
        set(hpopupPimaryChannel, 'Enable', 'on');
        
        previousValue = getCurrentPopupString(hpopupMaximaChannel);
        set(hpopupMaximaChannel, 'Value', 1);
        set(hpopupMaximaChannel, 'String', availableChannels);
        set(hpopupMaximaChannel, 'Value', getPopupIndex(hpopupPimaryChannel, previousValue));
        set(hpopupMaximaChannel, 'Enable', 'on');
    end

%% Auxiliary functions
    function str = getCurrentPopupString(hh)
        %# getCurrentPopupString returns the currently selected string in the popupmenu with handle hh
        
        %# could test input here
        if ~ishandle(hh) || strcmp(get(hh,'Type'),'popupmenu')
            error('getCurrentPopupString needs a handle to a popupmenu as input')
        end
        
        %# get the string - do it the readable way
        list = get(hh,'String');
        val = get(hh,'Value');
        if iscell(list)
            str = list{val};
        else
            str = list(val,:);
        end
    end

    function index = getPopupIndex(hh, str)
        %# getCurrentPopupString returns the currently selected string in the popupmenu with handle hh
        
        %# could test input here
        if ~ishandle(hh) || strcmp(get(hh,'Type'),'popupmenu')
            error('getCurrentPopupString needs a handle to a popupmenu as input')
        end
        
        %# get the string - do it the readable way
        list = get(hh,'String');
        index = find(strcmp(list, str));
        if(isempty(index))
            index = 1;
        end
    end
%% Key press functionality
%
    function fKeyPressFcn(~,keyInfo)
        if master.debugmode
            switch keyInfo.Key
                case 'period'
                    [mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
                    sourcePath = fullfile(mfilepath,'.debugfiles');
                    databaseFile = 'debug_database.txt';
                    database = readtable(fullfile(sourcePath, databaseFile), 'Delimiter', '\t');
                    
                    set(heditDatabasePath, 'String', fullfile(sourcePath, databaseFile));
                    set(heditRawDataPath, 'String', fullfile(sourcePath, 'RAW_DATA'));
                    set(heditSegmentDataPath, 'String', fullfile(sourcePath, 'SEGMENT_DATA'));
                    master.obj_fileManager.setDatabase(database);
                    master.obj_fileManager.setRawDataPath(get(heditRawDataPath, 'String'));
                    master.obj_fileManager.mainpath = sourcePath;
                    master.obj_fileManager.databaseFilename = databaseFile;
                    
                    availableGroups = unique(database.group_label);
                    set(hpopupGroupLabel, 'String', availableGroups);
                    set(hpopupGroupLabel, 'Enable', 'on');
                    master.obj_fileManager.setSelectedGroup(getCurrentPopupString(hpopupGroupLabel));
                    
                    populatePositionChannel
                    pushbuttonLoadData_Callback
            end
        end
    end
end