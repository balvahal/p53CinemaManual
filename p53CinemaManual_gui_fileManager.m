%% p53CinemaManual_gui_fileManager
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_fileManager(master)
%% Create the figure
%
set(0,'units','characters');
Char_SS = get(0,'screensize');
fwidth = 450/master.ppChar(1);
fheight = 300/master.ppChar(2);
fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Renderer','OpenGL','Position',[fx fy fwidth fheight]);
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
    'String','Select position','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Callback',{@popupStagePosition_Callback},'Enable', 'off', 'parent',f);

hy = hy - hheight - hmargin_short;
htextPimaryChannel = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Primary channel','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hpopupPimaryChannel = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Select channel','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Enable', 'off', 'parent',f);

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
    'Value',1,'parent',f);
hcheckboxPreprocess = uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Preprocess','Position',[hx + hmargin + 1.75*hwidth, hy - hheight, hwidth, hheight],...
    'Value',1,'parent',f);

%% Layout: Load button
hy = hy - hheight - hmargin;
heditImageResize = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Load','Position',[hx + hmargin + hwidth, hy, hwidth * 0.75, hheight],...
    'Callback',{@pushbuttonLoadData_Callback},'parent',f);

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
        
        set(heditDatabasePath, 'String', fullfile(sourcePath, databaseFile));
        set(heditRawDataPath, 'String', fullfile(sourcePath, 'RAW_DATA'));
        set(heditSegmentDataPath, 'String', fullfile(sourcePath, 'SEGMENT_DATA'));
        master.obj_fileManager.setDatabase(database);
        master.obj_fileManager.setRawDataPath(get(heditRawDataPath, 'String'));
        
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
        % Generate a sequence of images representing the current data to
        % visualize, save the timepoints each image corresponds to and sort
        % the filenames by timepoint.
        master.obj_fileManager.generateImageSequence;
        master.obj_fileManager.setPreprocessMode(get(hcheckboxPreprocess,'Value'));
        master.obj_fileManager.setPreallocateMode(get(hcheckboxPreallocate,'Value'));
        % Trigger image set-up in the viewer object
        
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
end