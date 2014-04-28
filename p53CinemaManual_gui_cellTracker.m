%% p53CinemaManual_gui_fileManager
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_cellTracker(master)
%% Create the figure
%
set(0,'units','characters');
Char_SS = get(0,'screensize');
fwidth = 450/master.ppChar(1);
fheight = 250/master.ppChar(2);
fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
fy = Char_SS(4) - (Char_SS(4)*.1 + fheight*2.75);
f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Renderer','OpenGL','Position',[fx fy fwidth fheight]);
%% Construct the components
hwidth = 120/master.ppChar(1);
hheight = 20/master.ppChar(2);
hmargin = 25/master.ppChar(2);
hmargin_short = 7/master.ppChar(2);
hx = 20/master.ppChar(1);
hy = fheight - (hmargin + hheight);

%% Layout: Start and pause tracking
htogglebuttonTrackingMode = uicontrol('Style','togglebutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Tracking mode','Position',[hx, hy, hwidth, hheight],...
    'Callback',{@togglebuttonTrackingMode_Callback},'Enable', 'on','parent',f);
hpushbuttonPause = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Pause','Enable','off','Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'parent',f);

%% Layout: Load and save tracking information
hy = hy - hheight - hmargin_short;
hpusbuttonLoadAnnotations = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Load tracks','Position',[hx, hy, hwidth, hheight],...
    'Callback', {@pushbuttonLoadAnnotations_Callback}, 'parent',f);
hpusbuttonSaveAnnotations = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Save tracks','Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Callback', {@pushbuttonSaveAnnotations_Callback}, 'Enable', 'on', 'parent',f);

%% Layout: Cell selection
hy = hy - hheight - hmargin_short;
hpopupSelectedCell = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','-- Select cell --','Position',[hx, hy, hwidth, hheight],...
    'Enable','off','Callback',{@popupSelectedCell_Callback}, 'parent',f);

%% Layout: Interaction options
hy = hy - hheight - hmargin;
htextFrameSkip = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Frame skip','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditFrameSkip = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','0','Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Enable', 'on', 'parent',f);
hy = hy - hheight - hmargin_short;
htextDistanceRadius = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Distance radius','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditDistanceRadius = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','30','Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Enable', 'on', 'parent',f);

%% Layout: special events

hy = hy - hmargin - hheight;
htextTrackEvent = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Cell fate','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hy = hy - hheight;
hbuttongroupTrackEvent = uibuttongroup('Visible','off','Units',get(f,'Units'),...
    'Position',[hx + hwidth + hmargin, hy, hwidth + hmargin_short, hheight * 2 + hmargin_short], 'Parent', f);
% Create three radio buttons in the button group.
u0 = uicontrol('Style','radiobutton','String','Division','Units',get(f,'Units'),...
    'Position',[0.5, hheight, hwidth - 1, hheight],'parent',hbuttongroupTrackEvent,'HandleVisibility','on');
u1 = uicontrol('Style','radiobutton','String','Death','Units',get(f,'Units'),...
    'Position',[0.5, 0, hwidth - 1, hheight],'parent',hbuttongroupTrackEvent,'HandleVisibility','on','Visible', 'on');
set(hbuttongroupTrackEvent,'Visible','on');


handles.htogglebuttonTrackingMode = htogglebuttonTrackingMode;
handles.hpushbuttonPause = hpushbuttonPause;
handles.hpusbuttonLoadAnnotations = hpusbuttonLoadAnnotations;
handles.hpusbuttonSaveAnnotations = hpusbuttonSaveAnnotations;
handles.hpopupSelectedCell = hpopupSelectedCell;
handles.htextFrameSkip = htextFrameSkip;
handles.heditFrameSkip = heditFrameSkip;
handles.htextDistanceRadius = htextDistanceRadius;
handles.heditDistanceRadius = heditDistanceRadius;
handles.hbuttongroupTrackEvent = hbuttongroupTrackEvent;
handles.u0 = u0;
handles.u1 = u1;
guidata(f, handles);

%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
    function togglebuttonTrackingMode_Callback(~,~)
        trackingStatus = get(htogglebuttonTrackingMode, 'Value');
        master.obj_imageViewer.obj_cellTracker.isTracking = trackingStatus;
        master.obj_imageViewer.obj_cellTracker.firstClick = 1;
    end

    function popupSelectedCell_Callback(~,~)
        selectedCell = str2double(getCurrentPopupString(hpopupSelectedCell));
        master.obj_imageViewer.setSelectedCell(selectedCell);
        master.obj_imageViewer.setImage;
    end

    function pushbuttonSaveAnnotations_Callback(~,~)
        selectedGroup = master.obj_fileManager.selectedGroup;
        selectedPosition = master.obj_fileManager.selectedPosition;
        databaseFile = fullfile(master.obj_fileManager.mainpath, master.obj_fileManager.databaseFilename);
        mainpath = master.obj_fileManager.mainpath;
        rawdatapath = master.obj_fileManager.rawdatapath;
        centroidsTracks = master.obj_imageViewer.obj_cellTracker.centroidsTracks;
        master.data = p53CinemaManual_object_data;
        master.data.importCentroidsTracks(centroidsTracks);
        centroidsDivisions = master.obj_imageViewer.obj_cellTracker.centroidsDivisions;
        centroidsDeath = master.obj_imageViewer.obj_cellTracker.centroidsDeath;
        
        uisave({'selectedGroup','selectedPosition','databaseFile','rawdatapath','centroidsTracks','centroidsDivisions','centroidsDeath'},...
            fullfile(mainpath, sprintf('tracking_s%d.mat', selectedPosition)));
    end

    function pushbuttonLoadAnnotations_Callback(~,~)
        [annotationFile, sourcePath] = uigetfile(fullfile(master.obj_fileManager.mainpath, '*.mat'));
        if(~isempty(annotationFile))
            loadStruct = load(fullfile(sourcePath, annotationFile));
            master.obj_imageViewer.obj_cellTracker.centroidsTracks = loadStruct.centroidsTracks;
            master.obj_imageViewer.obj_cellTracker.centroidsDivisions = loadStruct.centroidsDivisions;
            master.obj_imageViewer.obj_cellTracker.centroidsDeath = loadStruct.centroidsDeath;
            master.obj_imageViewer.selectedCell = 0;
            master.obj_imageViewer.obj_cellTracker.setAvailableCells;
            master.obj_imageViewer.setImage;
        end
        
    end

    function selcbk(source,eventdata)
        disp(source);
        disp([eventdata.EventName,'  ',...
            get(eventdata.OldValue,'String'),'  ', ...
            get(eventdata.NewValue,'String')]);
        disp(get(get(source,'SelectedObject'),'String'));
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