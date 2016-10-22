%% p53Cinema_singleCellAnnotation_gui_fileManager
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53Cinema_singleCellAnnotation_gui_featureTracker(master)
%% Create the figure
%
set(0,'units','characters');
Char_SS = get(0,'screensize');
fwidth = 450/master.ppChar(1);
fheight = 200/master.ppChar(2);
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
htogglebuttonAnnotationMode = uicontrol('Style','togglebutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Annotate mode','Position',[hx, hy, hwidth, hheight],...
    'Callback',{@togglebuttonAnnotateMode_Callback},'Enable', 'on','parent',f);
htogglebuttonDeletionMode = uicontrol('Style','togglebutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Delete mode','Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Callback',{@togglebuttonDeleteMode_Callback},'Enable', 'on','parent',f);

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
htextDistanceRadius = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Search radius','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditDistanceRadius = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','30','Position',[hx + hmargin + hwidth, hy, hwidth, hheight],...
    'Enable', 'on', 'parent',f);

handles.htogglebuttonAnnotationMode = htogglebuttonAnnotationMode;
handles.htogglebuttonDeletionMode = htogglebuttonDeletionMode;
handles.hpusbuttonLoadAnnotations = hpusbuttonLoadAnnotations;
handles.hpusbuttonSaveAnnotations = hpusbuttonSaveAnnotations;
handles.heditDistanceRadius = heditDistanceRadius;
handles.hpopupSelectedCell = hpopupSelectedCell;
guidata(f, handles);

%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
    function togglebuttonAnnotateMode_Callback(~,~)
        master.obj_imageViewer.obj_featureTracker.setAddMode;
    end

    function togglebuttonDeleteMode_Callback(~,~)
        master.obj_imageViewer.obj_featureTracker.setDeleteMode;
    end    

    function popupSelectedCell_Callback(~,~)
        selectedCell = str2double(getCurrentPopupString(hpopupSelectedCell));
        master.obj_imageViewer.setSelectedCell(selectedCell);
        master.obj_imageViewer.setImage;
    end

    function pushbuttonSaveAnnotations_Callback(~,~)
        selectedGroup = master.obj_fileManager.selectedGroup;
        selectedPosition = master.obj_fileManager.selectedPosition;
        selectedCell = master.obj_fileManager.selectedCell;
        databaseFile = fullfile(master.obj_fileManager.mainpath, master.obj_fileManager.databaseFilename);
        mainpath = master.obj_fileManager.mainpath;
        rawdatapath = master.obj_fileManager.rawdatapath;
        centroidsFeatures = master.obj_imageViewer.obj_featureTracker.centroidsFeatures;
        
        % A patchy solution: scale centroids given imageResizeFactor
        for i=1:length(centroidsFeatures.singleCells)
            centroidsFeatures.singleCells(i).point = centroidsFeatures.singleCells(i).point / master.obj_imageViewer.imageResizeFactor;
        end
        
        uisave({'selectedGroup', 'selectedCell', 'selectedPosition','databaseFile','rawdatapath','centroidsFeatures'},...
            fullfile(mainpath, sprintf('%s_s%d_tracking.mat', selectedGroup, selectedPosition)));
        
        % Bring back centroid positions to current scale
        for i=1:length(centroidsFeatures.singleCells)
            centroidsFeatures.singleCells(i).point = centroidsFeatures.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
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
            % table with the centroids and populate the centroidsFeatures
            % object (a patch at this moment)
            myCentroids = readtable(fullfile(sourcePath, annotationFile), 'Delimiter', '\t');
            [validFields, fieldLocation] = ismember({'centroid_col', 'centroid_row'}, myCentroids.Properties.VariableNames);
            if(sum(validFields) < 2)
                fprintf('Failed to import centroids. There should be a field names centroid_col and one named centroid_row\n');
            else
                for i=1:length(master.obj_imageViewer.obj_featureTracker.centroidsFeatures.getTrackedCellIds)
                    master.obj_imageViewer.obj_featureTracker.deleteCellData(i);
                end
                for i=1:min(max(myCentroids.timepoint), length(master.obj_imageViewer.obj_featureTracker.centroidsFeatures.singleCells))
                    subCentroids = table2array(myCentroids(myCentroids.timepoint == i, fieldLocation));
                    subIndex = double(myCentroids.cell_id(myCentroids.timepoint == i));
                    master.obj_imageViewer.obj_featureTracker.centroidsFeatures.singleCells(i).point(subIndex,:) = subCentroids * master.obj_imageViewer.imageResizeFactor;
                    
                    if(any(strcmp(myCentroids.Properties.VariableNames, 'value')))
                        subValues = myCentroids.value(myCentroids.timepoint == i);
                        master.obj_imageViewer.obj_featureTracker.centroidsFeatures.singleCells(i).value(subIndex) = subValues;
                    end
                end
            end
        else
            loadStruct = load(fullfile(sourcePath, annotationFile));
            for t=1:min(length(loadStruct.centroidsFeatures.singleCells), length(master.obj_imageViewer.obj_featureTracker.centroidsFeatures.singleCells))
                master.obj_imageViewer.obj_featureTracker.centroidsFeatures.singleCells(t).point = loadStruct.centroidsFeatures.singleCells(t).point;
                master.obj_imageViewer.obj_featureTracker.centroidsFeatures.singleCells(t).value = loadStruct.centroidsFeatures.singleCells(t).value;
            end
            % Make sure to rescale the centroids to fit current image size
            for i=1:length(master.obj_imageViewer.obj_featureTracker.centroidsFeatures.singleCells)
                master.obj_imageViewer.obj_featureTracker.centroidsFeatures.singleCells(i).point = master.obj_imageViewer.obj_featureTracker.centroidsFeatures.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
                master.obj_imageViewer.obj_featureTracker.centroidsDivisions.singleCells(i).point = master.obj_imageViewer.obj_featureTracker.centroidsDivisions.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
                master.obj_imageViewer.obj_featureTracker.centroidsDeath.singleCells(i).point = master.obj_imageViewer.obj_featureTracker.centroidsDeath.singleCells(i).point * master.obj_imageViewer.imageResizeFactor;
            end
        end
        master.obj_imageViewer.selectedCell = 0;
        master.obj_imageViewer.obj_featureTracker.setAvailableCells;
        master.obj_imageViewer.setImage;
        
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
end