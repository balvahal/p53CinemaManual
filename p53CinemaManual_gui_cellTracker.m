%% p53CinemaManual_gui_fileManager
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_cellTracker(master)
%% Create the figure
%
set(0,'units','characters');
Char_SS = get(0,'screensize');
fwidth = 450/master.ppChar(1);
fheight = 350/master.ppChar(2);
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
u0 = uicontrol('Style','pushbutton','String','Division','Units',get(f,'Units'),...
    'Position',[0.5, hheight, hwidth - 1, hheight],'parent',hbuttongroupTrackEvent,'HandleVisibility','on',...
    'Callback',{@u0Pushbutton_Callback});
u1 = uicontrol('Style','pushbutton','String','Death','Units',get(f,'Units'),...
    'Position',[0.5, 0, hwidth - 1, hheight],'parent',hbuttongroupTrackEvent,'HandleVisibility','on','Visible', 'on', ...
    'Callback',{@u1Pushbutton_Callback});
set(hbuttongroupTrackEvent,'Visible','on');

hy = hy - hmargin - hheight;
htextMergeSplit = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Merge/Split','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hy = hy - hheight;
hbuttongroupMergeSplit = uibuttongroup('Visible','off','Units',get(f,'Units'),...
    'Position',[hx + hwidth + hmargin, hy, hwidth + hmargin_short, hheight * 2 + hmargin_short], 'Parent', f);
% Create three radio buttons in the button group.
hmergePushbutton = uicontrol('Style','pushbutton','String','Merge','Units',get(f,'Units'),...
    'Position',[0.5, hheight, hwidth - 1, hheight],'parent',hbuttongroupMergeSplit,'HandleVisibility','on',...
    'Enable', 'off', 'Callback',{@mergePushbutton_Callback});
hsplitPushbutton = uicontrol('Style','pushbutton','String','Split','Units',get(f,'Units'),...
    'Position',[0.5, 0, hwidth - 1, hheight],'parent',hbuttongroupMergeSplit,'HandleVisibility','on','Visible', 'on', ...
    'Enable', 'off', 'Callback',{@splitPushbutton_Callback});
set(hbuttongroupMergeSplit,'Visible','on');

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
handles.hmergePushbutton = hmergePushbutton;
handles.hsplitPushbutton = hsplitPushbutton;
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
        master.data.importCentroidsTracks(centroidsTracks,selectedPosition);
        centroidsDivisions = master.obj_imageViewer.obj_cellTracker.centroidsDivisions;
        centroidsDeath = master.obj_imageViewer.obj_cellTracker.centroidsDeath;
        
        % A patchy solution: scale centroids given imageResizeFactor
        for i=1:length(centroidsTracks.singleCells)
            centroidsTracks.singleCells(i).point = centroidsTracks.singleCells(i).point / master.obj_imageViewer.imageResizeFactor;
            centroidsDivisions.singleCells(i).point = centroidsDivisions.singleCells(i).point / master.obj_imageViewer.imageResizeFactor;
            centroidsDeath.singleCells(i).point = centroidsDeath.singleCells(i).point / master.obj_imageViewer.imageResizeFactor;
        end
        
        uisave({'selectedGroup','selectedPosition','databaseFile','rawdatapath','centroidsTracks','centroidsDivisions','centroidsDeath'},...
            fullfile(mainpath, sprintf('%s_s%d_tracking.mat', selectedGroup, selectedPosition)));
        
        % Bring back centroid positions to current scale
        for i=1:length(centroidsTracks.singleCells)
            centroidsTracks.singleCells(i).point = centroidsTracks.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
            centroidsDivisions.singleCells(i).point = centroidsDivisions.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
            centroidsDeath.singleCells(i).point = centroidsDeath.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
        end
    end

    function pushbuttonLoadAnnotations_Callback(~,~)
        [annotationFile, sourcePath] = uigetfile(fullfile(master.obj_fileManager.mainpath, '*.mat;*.txt'));
        if(isempty(annotationFile))
            return
        end;
        [~,~,etx] = fileparts(annotationFile);
        if(strcmp(etx, '.txt'))
            % If the extension of the file is txt, assume that it is a
            % table with the centroids and populate the centroidsTracks
            % object (a patch at this moment)
            myCentroids = readtable(fullfile(sourcePath, annotationFile), 'Delimiter', '\t');
            [validFields, fieldLocation] = ismember({'centroid_col', 'centroid_row'}, myCentroids.Properties.VariableNames);
            if(sum(validFields) < 2)
                fprintf('Failed to import centroids. There should be a field names centroid_col and one named centroid_row\n');
            else
                for i=1:min(max(myCentroids.timepoint), length(master.obj_imageViewer.obj_cellTracker.centroidsTracks.singleCells))
                    subCentroids = table2array(myCentroids(myCentroids.timepoint == i, fieldLocation));
                    subIndex = double(myCentroids.cell_id(myCentroids.timepoint == i));
                    master.obj_imageViewer.obj_cellTracker.centroidsTracks.singleCells(i).point(subIndex,:) = subCentroids * master.obj_imageViewer.imageResizeFactor;
                    
                    if(any(strcmp(myCentroids.Properties.VariableNames, 'value')))
                        subValues = myCentroids.value(myCentroids.timepoint == i);
                        master.obj_imageViewer.obj_cellTracker.centroidsTracks.singleCells(i).value(subIndex) = subValues;
                    end
                    if(any(strcmp(myCentroids.Properties.VariableNames, 'division')))
                        subDivisions = logical(myCentroids.division(myCentroids.timepoint == i));
                        if(sum(subDivisions) > 0)
                            master.obj_imageViewer.obj_cellTracker.centroidsDivisions.singleCells(i).point(subIndex(subDivisions),:) = subCentroids(subDivisions,:) * master.obj_imageViewer.imageResizeFactor;
                        end
                    end
                    if(any(strcmp(myCentroids.Properties.VariableNames, 'death')))
                        subDeath = logical(myCentroids.division(myCentroids.timepoint == i));
                        if(sum(subDeath) > 0)
                            master.obj_imageViewer.obj_cellTracker.centroidsDeath.singleCells(i).point(subIndex(subDeath),:) = subCentroids(subDeath,:) * master.obj_imageViewer.imageResizeFactor;
                        end
                    end
                end
            end
        else
            loadStruct = load(fullfile(sourcePath, annotationFile));
            for t=1:min(length(loadStruct.centroidsTracks.singleCells), length(master.obj_imageViewer.obj_cellTracker.centroidsTracks.singleCells))
                master.obj_imageViewer.obj_cellTracker.centroidsTracks.singleCells(t).point = loadStruct.centroidsTracks.singleCells(t).point;
                master.obj_imageViewer.obj_cellTracker.centroidsTracks.singleCells(t).value = loadStruct.centroidsTracks.singleCells(t).value;
                if(any(strcmp(fieldnames(loadStruct), 'centroidsDivisions')))
                    master.obj_imageViewer.obj_cellTracker.centroidsDivisions.singleCells(t).point = loadStruct.centroidsDivisions.singleCells(t).point;
                    master.obj_imageViewer.obj_cellTracker.centroidsDivisions.singleCells(t).value = loadStruct.centroidsDivisions.singleCells(t).value;
                end
                if(any(strcmp(fieldnames(loadStruct), 'centroidsDeath')))
                    master.obj_imageViewer.obj_cellTracker.centroidsDivisions.singleCells(t).point = loadStruct.centroidsDivisions.singleCells(t).point;
                    master.obj_imageViewer.obj_cellTracker.centroidsDivisions.singleCells(t).value = loadStruct.centroidsDivisions.singleCells(t).value;
                end
            end
            % Make sure to rescale the centroids to fit current image size
            for i=1:length(master.obj_imageViewer.obj_cellTracker.centroidsTracks.singleCells)
                master.obj_imageViewer.obj_cellTracker.centroidsTracks.singleCells(i).point = master.obj_imageViewer.obj_cellTracker.centroidsTracks.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
                master.obj_imageViewer.obj_cellTracker.centroidsDivisions.singleCells(i).point = master.obj_imageViewer.obj_cellTracker.centroidsDivisions.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
                master.obj_imageViewer.obj_cellTracker.centroidsDeath.singleCells(i).point = master.obj_imageViewer.obj_cellTracker.centroidsDeath.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
            end
            
        end
        master.obj_imageViewer.selectedCell = 0;
        master.obj_imageViewer.obj_cellTracker.setAvailableCells;
        master.obj_imageViewer.setImage;
        
    end

    function selcbk(source,eventdata)
        disp(source);
        disp([eventdata.EventName,'  ',...
            get(eventdata.OldValue,'String'),'  ', ...
            get(eventdata.NewValue,'String')]);
        disp(get(get(source,'SelectedObject'),'String'));
    end

    function u0Pushbutton_Callback(source, eventdata)
        master.obj_imageViewer.obj_cellTracker.setDivisionEvent;
        master.obj_imageViewer.setImage;
    end

    function u1Pushbutton_Callback(source, eventdata)
        master.obj_imageViewer.obj_cellTracker.setDeathEvent;
        master.obj_imageViewer.setImage;
    end

    function mergePushbutton_Callback(source, eventdata)
        currentTimepoint = master.obj_imageViewer.currentTimepoint;
        selectedCell = master.obj_imageViewer.selectedCell;
        potentialMergeCell = master.obj_imageViewer.potentialMergeCell;
        
        % Determine merge directionality
        centroidsTracks = master.obj_imageViewer.obj_cellTracker.centroidsTracks;
        mergingCellTrack = centroidsTracks.getCellTrack(potentialMergeCell);
        if(sum(mergingCellTrack(1:currentTimepoint,1) > 0) > sum(mergingCellTrack(currentTimepoint:end,1) > 0))
            replaceTimepoints = 1:currentTimepoint;
        else
            replaceTimepoints = currentTimepoint:size(mergingCellTrack,1);
        end
        
        master.obj_imageViewer.obj_cellTracker.replaceCellTimepoints(potentialMergeCell, selectedCell, replaceTimepoints);
        master.obj_imageViewer.obj_cellTracker.deleteCellData(potentialMergeCell);
        master.obj_imageViewer.obj_cellTracker.setEnableMerge('off');
        master.obj_imageViewer.potentialMergeCell = 0;
        master.obj_imageViewer.setImage;
        master.obj_imageViewer.obj_cellTracker.setAvailableCells;
    end

    function splitPushbutton_Callback(source, eventdata)
        currentTimepoint = master.obj_imageViewer.currentTimepoint;
        selectedCell = master.obj_imageViewer.selectedCell;
        maxTimepoint = length(master.obj_imageViewer.obj_cellTracker.centroidsDivisions.singleCells);

        newCell = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getAvailableCellId;
        master.obj_imageViewer.obj_cellTracker.replaceCellTimepoints(selectedCell, newCell, (currentTimepoint+1):maxTimepoint);
        master.obj_imageViewer.obj_cellTracker.deleteCellTimepoints(selectedCell, (currentTimepoint+1):maxTimepoint);
        master.obj_imageViewer.obj_cellTracker.setEnableSplit('off');
        master.obj_imageViewer.obj_cellTracker.setAvailableCells;
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