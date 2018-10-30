%% p53CinemaManual_gui_fileManager
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_cellTracker(master)
%% Create the figure
%
set(0,'units','characters');
Char_SS = get(0,'screensize');
fwidth = 450/master.ppChar(1);
fheight = 430/master.ppChar(2);
fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
fy = Char_SS(4) - (Char_SS(4)*.1 + fheight*2.75);
f = figure('Visible','off','Units','characters','Name','Cell Tracker','MenuBar','none',...
    'CloseRequestFcn',{@fCloseRequestFcn},...
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
hpushButtonCreateEditTrack = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Create/Edit track','Position',[hx, hy-hheight, hwidth, hheight],...
    'Callback',{@pushbuttonCreateEditTrack_Callback},'Enable', 'on','parent',f);

hbuttonGroupTrackingDirection = uibuttongroup('Units','characters',...
    'Position',[hx + hmargin + hwidth, hy - hheight, hwidth * 1.1, hheight * 2.3],...
    'parent',f, 'SelectionChangeFcn',@trackingDirectionChange_Callback);
hradiobuttonForward = uicontrol('Style','radiobutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Forward','Position',[0,hheight,hwidth,hheight],...
    'Enable', 'on','parent',hbuttonGroupTrackingDirection, 'Tag', 'Forward');
hradiobuttonBackward = uicontrol('Style','radiobutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Backward','Position',[0,0,hwidth,hheight],...
    'Enable', 'on','parent',hbuttonGroupTrackingDirection, 'Tag', 'Backward');

hbuttonGroupTrackingStyle = uibuttongroup('Units','characters',...
    'Position',[hx + hmargin + hwidth*2, hy - hheight, hwidth * 1.1, hheight * 2.3],...
    'parent',f, 'SelectionChangeFcn',@trackingStyleChange_Callback);
hradiobuttonDontPropagate = uicontrol('Style','radiobutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Frame-by-frame','Position',[0,hheight,hwidth,hheight],...
    'Enable', 'on','parent',hbuttonGroupTrackingStyle, 'Tag', 'SingleFramePropagate');
hradiobuttonPropagate = uicontrol('Style','radiobutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Propagate','Position',[0,0,hwidth,hheight],...
    'Enable', 'on','parent',hbuttonGroupTrackingStyle, 'Tag', 'PropagateTracking');

hy = hy - hheight * 2 - hmargin_short;
hcheckboxPlayWhileTracking =  uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Play and Track','Value',1,'Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Callback', {@checkboxPlayWhileTracking_Callback},'parent',f);
htextTimeDelay = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','center',...
    'String','Delay','Position',[hx + hmargin + hwidth*2,hy,hwidth*0.5,hheight],...
    'parent',f);
heditTimeDelay = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','0','Position',[hx + hmargin*2 + hwidth*2.5,hy,hwidth*0.5,hheight],...
    'Enable', 'on', 'parent',f,'Callback', {@editTimeDelay_Callback});

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
hcheckboxAutoCenter = uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Auto-center','Value',0,'Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Callback', {@checkboxAutoCenter_Callback},'parent',f);
hpushbuttonMakeMovie = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Make movie','Position',[hx + 2*hmargin + 2*hwidth, hy, hwidth, hheight],...
    'Callback', {@pushbuttonMakeMovie_Callback},'parent',f);

%% Layout: Interaction options
hy = hy - hheight - hmargin;
htextDistanceRadius = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Search radius','Position',[hx, hy, hwidth * 0.8, hheight],...
    'parent',f);
heditDistanceRadius = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','30','Position',[hx + hmargin + hwidth*0.8, hy, hwidth * 0.25, hheight],...
    'Enable', 'on', 'parent',f);
htextBlurRadius = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Blur radius','Position',[hx + hmargin*2 + hwidth*1.2, hy, hwidth * 0.6, hheight],...
    'parent',f);
heditBlurRadius = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String',master.obj_fileManager.cellSize,'Position',[hx + hmargin*3 + hwidth*1.75, hy, hwidth*0.3, hheight],...
    'Enable', 'on', 'parent',f);
[hprogressbarhandleFindCells, hprogressbarFindCells] = javacomponent('javax.swing.JProgressBar');
set(hprogressbarFindCells, 'Units', get(f, 'Units'), 'Position', [hx + hmargin*2 + hwidth*2.3, hy, hwidth*0.7, hheight], 'Parent', f);

hy = hy - hheight - hmargin_short;
htextExclusionRadius = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Exclusion radius','Position',[hx, hy, hwidth*0.8, hheight],...
    'parent',f);
heditExclusionRadius = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','5','Position',[hx + hmargin + hwidth*0.8, hy, hwidth*0.25, hheight],...
    'Enable', 'off', 'parent',f);
hFindCellsPushbutton = uicontrol('Style','pushbutton','String','Find cells','Units',get(f,'Units'),...
    'Position',[hx + hmargin*2 + hwidth*1.2, hy, hwidth*0.8, hheight],'parent',f,'HandleVisibility','on',...
    'Callback',{@FindCellsPushbutton_Callback});
hTextFindCellsLoadingBar = uicontrol('Style','text','Units','characters',...
    'FontSize',8,'FontName','Arial','HorizontalAlignment','left',...
    'String','Finding cells','Position',[hx + hmargin*2 + hwidth*2.3, hy, hwidth*0.7, hheight],...
    'parent',f);


%% Layout delete functions
hy = hy - hmargin - hheight;
htextDeleteTracks = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Delete','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hy = hy - hheight;
hbuttongroupDeleteFunctions = uibuttongroup('Visible','off','Units',get(f,'Units'),...
    'Position',[hx + hwidth + hmargin, hy, hwidth + hmargin_short, hheight * 2 + hmargin_short], 'Parent', f);
% Create three radio buttons in the button group.
hDeleteForwardPushbutton = uicontrol('Style','pushbutton','String','Delete forward','Units',get(f,'Units'),...
    'Position',[0.5, hheight, hwidth - 1, hheight],'parent',hbuttongroupDeleteFunctions,'HandleVisibility','on',...
    'Callback',{@DeleteForwardPushbutton_Callback});
hDeleteBackwardsPushbutton = uicontrol('Style','pushbutton','String','Delete backwards','Units',get(f,'Units'),...
    'Position',[0.5, 0, hwidth - 1, hheight],'parent',hbuttongroupDeleteFunctions,'HandleVisibility','on','Visible', 'on', ...
    'Callback',{@DeleteBackwardsPushbutton_Callback});
set(hbuttongroupDeleteFunctions,'Visible','on');


%% Layout: special events

hy = hy - hmargin - hheight;
htextTrackEvent = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Cell fate','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hy = hy - hheight;
hbuttongroupTrackEvent = uibuttongroup('Visible','off','Units',get(f,'Units'),...
    'Position',[hx + hwidth + hmargin, hy, 2*hwidth + 4*hmargin_short, hheight * 2 + hmargin_short], 'Parent', f);
% Create three radio buttons in the button group.
u0 = uicontrol('Style','pushbutton','String','Division','Units',get(f,'Units'),...
    'Position',[0.5, hheight, hwidth - 1, hheight],'parent',hbuttongroupTrackEvent,'HandleVisibility','on',...
    'Callback',{@u0Pushbutton_Callback});
trackSisterPushbutton = uicontrol('Style','pushbutton','String','Follow sister','Units',get(f,'Units'),...
    'Position',[hwidth + hmargin_short + 0.5, hheight, hwidth, hheight],'Enable','off','parent',hbuttongroupTrackEvent,'HandleVisibility','on',...
    'Callback',{@trackSisterPushbutton_Callback});
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

handles.hpushButtonCreateEditTrack = hpushButtonCreateEditTrack;
handles.htogglebuttonTrackingMode = htogglebuttonTrackingMode;
handles.hradiobuttonDontPropagate = hradiobuttonDontPropagate;
handles.hradiobuttonPropagate = hradiobuttonPropagate;
handles.hradiobuttonForward = hradiobuttonForward;
handles.hradiobuttonBackward = hradiobuttonBackward;
handles.heditTimeDelay = heditTimeDelay;

handles.hpusbuttonLoadAnnotations = hpusbuttonLoadAnnotations;
handles.hpusbuttonSaveAnnotations = hpusbuttonSaveAnnotations;
handles.hpopupSelectedCell = hpopupSelectedCell;
handles.hcheckboxAutoCenter = hcheckboxAutoCenter;
handles.heditExclusionRadius = heditExclusionRadius;
handles.htextExclusionRadius = htextExclusionRadius;
handles.htextDistanceRadius = htextDistanceRadius;
handles.heditDistanceRadius = heditDistanceRadius;
handles.hbuttongroupTrackEvent = hbuttongroupTrackEvent;
handles.u0 = u0;
handles.u1 = u1;
handles.hmergePushbutton = hmergePushbutton;
handles.hsplitPushbutton = hsplitPushbutton;
handles.trackSisterPushbutton = trackSisterPushbutton;
handles.hprogressbarhandleFindCells = hprogressbarhandleFindCells;
handles.hprogressbarFindCells = hprogressbarFindCells;
guidata(f, handles);

%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
    function fCloseRequestFcn(~,~)
    end

    function pushbuttonMakeMovie_Callback(~,~)
        baseDirectory = master.obj_fileManager.mainpath;
        moviesDirectory = fullfile(baseDirectory, 'Movies');
        if(~exist(moviesDirectory, 'dir'))
            mkdir(moviesDirectory)
        end
        if(master.obj_imageViewer.selectedCell > 0)
            movieFilename = sprintf('%s_s%d_w%s_c%d.TIF', master.obj_fileManager.selectedGroup, master.obj_fileManager.selectedPosition, master.obj_fileManager.selectedChannel, master.obj_imageViewer.selectedCell);
            centroids = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getCellTrack(master.obj_imageViewer.selectedCell);
            centroids = centroids(master.obj_fileManager.currentImageTimepoints,:);
            set(hpushbuttonMakeMovie, 'Enable', 'off');
            createSingleCellMovie(master.obj_imageViewer.imageBuffer, centroids, [], [80,80], fullfile(moviesDirectory, movieFilename))
            set(hpushbuttonMakeMovie, 'Enable', 'on');
        end
    end

    function togglebuttonTrackingMode_Callback(~,~)
        trackingStatus = get(htogglebuttonTrackingMode, 'Value');
        master.obj_imageViewer.obj_cellTracker.isTracking = trackingStatus;
        master.obj_imageViewer.obj_cellTracker.firstClick = 1;
    end
    
    function trackingStyleChange_Callback(~,~)
        master.obj_imageViewer.obj_cellTracker.trackingStyle = get(get(hbuttonGroupTrackingStyle, 'SelectedObject'), 'Tag');
    end

    function trackingDirectionChange_Callback(~,~)
        master.obj_imageViewer.obj_cellTracker.trackingDirection = get(get(hbuttonGroupTrackingDirection, 'SelectedObject'), 'Tag');
    end

    function editTimeDelay_Callback(~,~)
        timeDelay = str2double(get(heditTimeDelay, 'String'));
        master.obj_imageViewer.obj_cellTracker.trackingDelay = timeDelay;
    end
    
    function popupSelectedCell_Callback(~,~)
        selectedCell = str2double(getCurrentPopupString(hpopupSelectedCell));
        master.obj_imageViewer.setSelectedCell(selectedCell);
        master.obj_imageViewer.setImage;
    end

    function checkboxAutoCenter_Callback(~,~)
        master.obj_imageViewer.setImage;
    end

    function checkboxPlayWhileTracking_Callback(~,~)
        master.obj_imageViewer.obj_cellTracker.setPlayWhileTracking(get(hcheckboxPlayWhileTracking, 'Value'));
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
                for i=1:length(master.obj_imageViewer.obj_cellTracker.centroidsTracks.getTrackedCellIds)
                    master.obj_imageViewer.obj_cellTracker.deleteCellData(i);
                end
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
                        subDeath = logical(myCentroids.death(myCentroids.timepoint == i));
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
                    master.obj_imageViewer.obj_cellTracker.centroidsDeath.singleCells(t).point = loadStruct.centroidsDeath.singleCells(t).point;
                    master.obj_imageViewer.obj_cellTracker.centroidsDeath.singleCells(t).value = loadStruct.centroidsDeath.singleCells(t).value;
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

    function FindCellsPushbutton_Callback(~,~)
        master.obj_imageViewer.obj_cellTracker.findCells(str2num(get(heditBlurRadius, 'String')));
    end

    function selcbk(source,eventdata)
        disp(source);
        disp([eventdata.EventName,'  ',...
            get(eventdata.OldValue,'String'),'  ', ...
            get(eventdata.NewValue,'String')]);
        disp(get(get(source,'SelectedObject'),'String'));
    end

    function DeleteForwardPushbutton_Callback(~,~)
        master.obj_imageViewer.deleteSelectedCellForward;
    end

    function DeleteBackwardsPushbutton_Callback(~,~)
        master.obj_imageViewer.deleteSelectedCellBackwards;
    end

    function u0Pushbutton_Callback(source, eventdata)
        master.obj_imageViewer.obj_cellTracker.setDivisionEvent;
        master.obj_imageViewer.setImage;
    end

    function u1Pushbutton_Callback(source, eventdata)
        master.obj_imageViewer.obj_cellTracker.setDeathEvent;
        master.obj_imageViewer.setImage;
    end

    function trackSisterPushbutton_Callback(source, eventdata)
        master.obj_imageViewer.obj_cellTracker.trackSister;
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

    function pushbuttonCreateEditTrack_Callback(source, eventdata)
        master.obj_imageViewer.obj_cellTracker.firstClick = 1;
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