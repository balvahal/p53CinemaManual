function varargout = singleCellFollowing_main(varargin)
% SINGLECELLFOLLOWING_MAIN MATLAB code for singleCellFollowing_main.fig
%      SINGLECELLFOLLOWING_MAIN, by itself, creates a new SINGLECELLFOLLOWING_MAIN or raises the existing
%      singleton*.
%
%      H = SINGLECELLFOLLOWING_MAIN returns the handle to a new SINGLECELLFOLLOWING_MAIN or the handle to
%      the existing singleton*.
%
%      SINGLECELLFOLLOWING_MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLECELLFOLLOWING_MAIN.M with the given input arguments.
%
%      SINGLECELLFOLLOWING_MAIN('Property','Value',...) creates a new SINGLECELLFOLLOWING_MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before singleCellFollowing_main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to singleCellFollowing_main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help singleCellFollowing_main

% Last Modified by GUIDE v2.5 27-Mar-2014 11:55:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @singleCellFollowing_main_OpeningFcn, ...
                   'gui_OutputFcn',  @singleCellFollowing_main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before singleCellFollowing_main is made visible.
function singleCellFollowing_main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to singleCellFollowing_main (see VARARGIN)

% Choose default command line output for singleCellFollowing_main
handles.output = hObject;

handles.maxWidth = 600;
handles.maxHeight = 500;
handles.minWidth = 50;
handles.minHeight = 50;
handles.marginLevel1 = 10;
handles.marginLevel2 = 20;
handles.imageScanningMode = 0;
handles.isInsideCanvas = 0;
handles.previousPosition = [-1,-1];
handles.imorigin = [1,1];
handles.previousCell = [-1,-1];
handles.isTracking = 0;
handles.cell_id = 1;
setappdata(handles.figure1, 'selectedCell', -1);

[handles.progressBar, handles.progressBarFigure] = javacomponent('javax.swing.JProgressBar');
set(handles.progressBarFigure, 'Units', get(handles.figure1, 'Units'));

myunits = get(0,'units');
set(0,'units','pixels');
Pix_SS = get(0,'screensize');
set(0,'units','characters');
Char_SS = get(0,'screensize');
ppChar = Pix_SS./Char_SS;
handles.ppChar = ppChar(3:4);
set(0,'units',myunits);
handles.definedSizePixels = [handles.maxWidth, handles.maxHeight];
handles.definedSize = handles.definedSizePixels ./ handles.ppChar;
changeObjectPosition(handles.imageCanvas, 3:4, handles.definedSize);

organizeLayout(handles);

axes(handles.imageCanvas);
image(zeros(1,1));
colormap('gray');

guidata(hObject, handles);

% UIWAIT makes singleCellFollowing_main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = singleCellFollowing_main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function movieSlider_Callback(hObject, eventdata, handles)
indexSliderValue = getSliderIndex(handles);
imageCanvas_setImage(handles, indexSliderValue);

function index = getSliderIndex(handles)
currentSliderValue = get(handles.movieSlider, 'Value');
stepSize = get(handles.movieSlider, 'SliderStep');
index = round(currentSliderValue / stepSize(1) + 1);

function value = getSliderValue(handles, index)
if(index > length(handles.imageFilenames) || index < 1)
    return;
end

stepSize = get(handles.movieSlider, 'SliderStep');
value = (index - 1) * stepSize(1);

function handles = imageCanvas_setImage(handles, index)
handles = guidata(handles.figure1);
if(strcmp(getCurrentPopupString(handles.channelToogleSelection), getCurrentPopupString(handles.channelSelection)))
    % SPEED UP ATTEMPT: load image from preallocated array
    IM = handles.imageSequence(:,:,index);
else
    IM = im2uint8(imnormalize(imresize(imread(fullfile(handles.rawdataFolder, handles.imageFilenames{index})), [handles.totalSize(1), handles.totalSize(2)])));
end

set(handles.currentFrameText, 'String', num2str(index));
set(handles.frameProgressionLabel, 'String', [num2str(index) '/' num2str(length(handles.imageFilenames))]);
set(handles.movieSlider, 'Value', getSliderValue(handles, index));
set(handles.currentFilenameLabel, 'string', handles.imageFilenames{index});
setappdata(handles.figure1, 'IM', IM);

currentFrame = index;
availableCells = [0,find(handles.annotationLayers.pointLayer(currentFrame).point(:,1))']';
set(handles.highlightedCellPopupMenu, 'String', num2str(availableCells));
set(handles.highlightedCellPopupMenu, 'Value', 1);
if(handles.highlightedCell > 0 && ~isempty(handles.highlightedCell))
    highlightedCellPosition = handles.annotationLayers.pointLayer(currentFrame).point(handles.highlightedCell,:);
    cellOptions = str2num(get(handles.highlightedCellPopupMenu, 'String'));
    value = find(cellOptions == handles.highlightedCell);
    if(isempty(value))
        value = 1;
    end
    set(handles.highlightedCellPopupMenu, 'Value', value);
else
    highlightedCellPosition = [0,0];
end


subImage = prepareOverlayImage(handles);
centroids = getValidCentroids(handles.annotationLayers.pointLayer(currentFrame));
divisionPoints = getValidCentroids(handles.annotationLayers.divisionLayer(currentFrame));
set(handles.implot, 'CData', subImage);
delete(findobj(handles.imageCanvas, 'Color', 'red'));
delete(findobj(handles.imageCanvas, 'Color', 'green'));
hold(handles.imageCanvas, 'on');
plot(centroids(:,1), centroids(:,2), 'r*');
plot(divisionPoints(:,1), divisionPoints(:,2), 'g*');
plot(highlightedCellPosition(1), highlightedCellPosition(2), 'o', 'MarkerSize', 20, 'color', [0,1,0], 'linewidth', 2);
hold(handles.imageCanvas, 'off');

if(~get(handles.startStopTrackToogleButton, 'Value'))
    drawnow;
end

function handles = imageCanvas_refreshImage(handles)
handles = guidata(handles.figure1);
transformedPoint = [getappdata(handles.figure1, 'xloc'), getappdata(handles.figure1, 'yloc')];
subImage = prepareOverlayImage(handles);
currentFrame = str2double(get(handles.currentFrameText, 'String'));
if(handles.highlightedCell > 0 && ~isempty(handles.highlightedCell))
    highlightedCellPosition = handles.annotationLayers.pointLayer(currentFrame).point(handles.highlightedCell,:);
else
    highlightedCellPosition = [0,0];
end
centroids = getValidCentroids(handles.annotationLayers.pointLayer(currentFrame));
divisionPoints = getValidCentroids(handles.annotationLayers.divisionLayer(currentFrame));
set(handles.implot, 'CData', subImage);

delete(findobj(handles.imageCanvas, 'Color', 'red'));
delete(findobj(handles.imageCanvas, 'Color', 'green'));
hold(handles.imageCanvas, 'on');
plot(centroids(:,1), centroids(:,2), 'r*');
plot(divisionPoints(:,1), divisionPoints(:,2), 'g*');
plot(highlightedCellPosition(1), highlightedCellPosition(2), 'o', 'MarkerSize', 20, 'color', [0,1,0], 'linewidth', 2);
hold(handles.imageCanvas, 'off');

function [subImage] = prepareOverlayImage(handles)
currentTime = handles.imageTimepoints(str2double(get(handles.currentFrameText, 'String')));
IM = getappdata(handles.figure1, 'IM');
transformedPoint = [getappdata(handles.figure1, 'xloc'), getappdata(handles.figure1, 'yloc')];

trackedCentroids = handles.annotationLayers.pointLayer(currentTime).point(:,:);
subsettingRectangle = {handles.imorigin(2):(handles.imorigin(2) + handles.definedSizePixels(1)-1), handles.imorigin(1):(handles.imorigin(1) + handles.definedSizePixels(2)-1)};
subImage = IM(subsettingRectangle{1}, subsettingRectangle{2});

function centroids = getValidCentroids(centroidArray)
%currentFrame = str2double(get(handles.currentFrameText, 'String'));
centroids = centroidArray.point;
centroids = centroids(centroids(:,1) > 0,:);

% --- Executes during object creation, after setting all properties.
function movieSlider_CreateFcn(hObject, eventdata, handles)
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in gotoFirstFrameButton.
function gotoFirstFrameButton_Callback(hObject, eventdata, handles)
% For some reason, drawing just once 
handles = imageCanvas_setImage(handles, 1);
handles = imageCanvas_setImage(handles, 1);

% --- Executes on button press in gotoLastFrameButton.
function gotoLastFrameButton_Callback(hObject, eventdata, handles)
handles = imageCanvas_setImage(handles, length(handles.imageFilenames));
handles = imageCanvas_setImage(handles, length(handles.imageFilenames));

% --- Executes during object creation, after setting all properties.
function currentFrameText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in gotoFrameButton.
function gotoFrameButton_Callback(hObject, eventdata, handles)
index = str2double(get(handles.currentFrameText, 'String'));
if(index > 0 && index <= length(handles.imageFilenames))
    imageCanvas_setImage(handles, index);
    imageCanvas_setImage(handles, index);
else
    index = getSliderIndex(handles);
    set(handles.currentFrameText, 'String', num2str(index));
end

% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
if(strcmp(get(handles.movieSlider, 'Enable'), 'off'))
    return;
end
currentPoint = get(handles.figure1, 'CurrentPoint');
imageCanvasPosition = get(handles.imageCanvas, 'Position');
if(isInsideCoordinates(currentPoint, imageCanvasPosition))
    handles.isInsideCanvas = 1;
    transformedPoint = getTransformedLocation(currentPoint, imageCanvasPosition, handles.imageCanvas);
    setappdata(handles.figure1, 'xloc', transformedPoint(1));
    setappdata(handles.figure1, 'yloc', transformedPoint(2));
    if(getappdata(handles.figure1, 'isEditing'))
        set(handles.figure1, 'Pointer', 'hand');
    end
    if(handles.imageScanningMode)
        set(handles.figure1, 'Pointer', 'crosshair');
        if(handles.previousPosition(1) ~= -1)
            displacement = transformedPoint - handles.previousPosition;
            handles.imorigin = evaluateNewOrigin(handles, uint16([handles.imorigin(1) - displacement(1), handles.imorigin(2) - displacement(2)]));
            guidata(hObject, handles);
        end
        handles.previousPosition = transformedPoint;
    end
    imageCanvas_refreshImage(handles);
else
    set(handles.figure1, 'Pointer', 'arrow');
    %handles.previousPosition = [-1,-1];
    handles.isInsideCanvas = 0;
end
guidata(hObject, handles);

function newOrigin = evaluateNewOrigin(handles, newOrigin)
newOrigin(1) = min(max(newOrigin(1),1), handles.totalSize(2) - handles.definedSizePixels(2)+1);
newOrigin(2) = min(max(newOrigin(2),1), handles.totalSize(1) - handles.definedSizePixels(1)+1);

function transformedPoint = getTransformedLocation(currentPoint, imageCanvasPosition, axesHandle)
xlimit = get(axesHandle, 'xlim');
ylimit = get(axesHandle, 'ylim');
xlimit(1) = ceil(xlimit(1)); xlimit(2) = floor(xlimit(2));
ylimit(1) = ceil(ylimit(1)); ylimit(2) = floor(ylimit(2));
transformedPoint = [imageCanvasPosition(3) - currentPoint(1), currentPoint(2) - imageCanvasPosition(2)];
scalingFactor = [diff(xlimit)-1, diff(ylimit)-1] ./ imageCanvasPosition(3:4);
transformedPoint = round([xlimit(2), ylimit(1)] - transformedPoint .* scalingFactor + [xlimit(1), ylimit(2)]);
transformedPoint(1) = max(transformedPoint(1), xlimit(1)); transformedPoint(1) = min(transformedPoint(1), xlimit(2));
transformedPoint(2) = max(transformedPoint(2), ylimit(1)); transformedPoint(2) = min(transformedPoint(2), ylimit(2));


function result = isInsideCoordinates(point, rectangle)
result = point(1) >= rectangle(1) && point(2) >= rectangle(2) && point(1) < rectangle(1) + rectangle(3) && point(2) < rectangle(2) + rectangle(4);


% --------------------------------------------------------------------
function fileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to fileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function loadDataMenu_Callback(hObject, eventdata, handles)
% hObject    handle to loadDataMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes during object creation, after setting all properties.
function filepathText_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browseFilesButton.
function browseFilesButton_Callback(hObject, eventdata, handles)
% Retrieve database file with dialog box and set filepath
[databaseFile, sourcePath] = uigetfile('./*.txt');
set(handles.filepathText, 'String', sourcePath);
% Open database file and get the unique 'groups' in order to populate the
database = readtable(fullfile(sourcePath, databaseFile), 'Delimiter', '\t');
% Set the database and databaseColnames as gui datasets
handles.database = database;
handles.databaseFile = databaseFile;
handles.sourcePath = sourcePath;
guidata(hObject, handles);

% Get group labels and populate 'imageGroupPopupMenu'
handles = populateGroupStageChannelMenu(handles);
set(handles.imageGroupSelection, 'Enable', 'on');
set(handles.stagePositionSelection, 'Enable', 'on');
set(handles.channelSelection, 'Enable', 'on');
set(handles.channelToogleSelection, 'Enable', 'on');
set(handles.loadDatasetButton, 'Enable', 'on');

function handles = populateGroupStageChannelMenu(handles)
groupLabels = handles.database.group_label;
set(handles.imageGroupSelection, 'String', unique(groupLabels));
selectedGroup = getCurrentPopupString(handles.imageGroupSelection);
% Get unique positions for this particular group and populate
positionLabels = handles.database.position_number;
positions = positionLabels(strcmp(groupLabels, selectedGroup));
set(handles.stagePositionSelection, 'String', num2str(unique(positions)));
selectedStagePosition = getCurrentPopupString(handles.stagePositionSelection);
% Get unique channels for imagegroup and stageposition and populate channel
channelLabels = handles.database.channel_name;
channels = channelLabels(positionLabels == str2double(selectedStagePosition) & strcmp(groupLabels, selectedGroup));
set(handles.channelSelection, 'String', unique(channels));
set(handles.channelToogleSelection, 'String', unique(channels));

% --- Executes on selection change in imageGroupSelection.
function imageGroupSelection_Callback(hObject, eventdata, handles)
set(handles.stagePositionSelection, 'Value', 1);
set(handles.channelSelection, 'Value', 1);
populateGroupStageChannelMenu(handles);


% --- Executes during object creation, after setting all properties.
function imageGroupSelection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in stagePositionSelection.
function stagePositionSelection_Callback(hObject, eventdata, handles)
set(handles.channelSelection, 'Value', 1);
populateGroupStageChannelMenu(handles);

% --- Executes during object creation, after setting all properties.
function stagePositionSelection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function channelSelection_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadDatasetButton.
function loadDatasetButton_Callback(hObject, eventdata, handles)
selectedGroup = getCurrentPopupString(handles.imageGroupSelection);
selectedChannel = getCurrentPopupString(handles.channelSelection);
selectedPosition = getCurrentPopupString(handles.stagePositionSelection);
set(handles.channelToogleSelection, 'Value', get(handles.channelSelection, 'Value'));
setappdata(handles.figure1, 'isEditing',  0);
setappdata(handles.figure1, 'autoTracking', 0);

[handles.imageFilenames, handles.imageTimepoints, handles.dataLength] = generateImageSequence(handles);
handles.primaryChannel = selectedChannel;

handles.selectedGroup = selectedGroup;
handles.selectedChannel = selectedChannel;
handles.selectedPosition = selectedPosition;

rawdataFolder = fullfile(handles.sourcePath, 'RAW_DATA');
handles.rawdataFolder = rawdataFolder;

handles.imResizeFactor = 1;
IM = imresize(imread(fullfile(handles.rawdataFolder, handles.imageFilenames{1})), handles.imResizeFactor);
handles.totalSize = size(IM);
% SPEED UP ATTEMPT: PREALLOCATE IMAGES
handles.imageSequence = uint8(zeros(size(IM,1), size(IM,2), length(handles.imageFilenames)));
set(handles.progressBar, 'Value', 0);
set(handles.progressBar, 'Maximum', length(handles.imageFilenames));
for i=1:length(handles.imageFilenames)
    handles.imageSequence(:,:,i) = im2uint8(imnormalize(imresize(imread(fullfile(handles.rawdataFolder, handles.imageFilenames{i})), [handles.totalSize(1), handles.totalSize(2)])));
    set(handles.progressBar, 'Value', i);
end

maxPointsPerImage = 1000;
handles.annotationLayers.pointLayer = repmat(struct('n', 0, 'point', zeros(maxPointsPerImage,2), 'value', zeros(maxPointsPerImage,1), 'version', zeros(maxPointsPerImage,1)), handles.dataLength, 1);
handles.annotationLayers.divisionLayer = repmat(struct('point', zeros(maxPointsPerImage,2),'cell_id', zeros(maxPointsPerImage,1)), handles.dataLength, 1);
handles.annotationLayers.localMaximaLayer = repmat(struct('point', zeros(maxPointsPerImage,2), 'value', zeros(maxPointsPerImage,1), 'cell', zeros(maxPointsPerImage,1)), handles.dataLength, 1);

newHeight = max(min(handles.maxHeight, str2double(get(handles.canvasHeightText, 'String'))), handles.minHeight);
newWidth = max(min(handles.maxWidth, str2double(get(handles.canvasWidthText, 'String'))), handles.minWidth);
newHeight = min(newHeight, size(IM,1));
newWidth = min(newWidth, size(IM,2));

currentAxesUnits = get(handles.imageCanvas, 'Units');
set(handles.imageCanvas, 'Units', 'Pixels');
canvasPosition = get(handles.imageCanvas, 'Position');
handles.canvasSize = [canvasPosition(4), canvasPosition(3)];
definedSize = [newHeight, newWidth]; 
handles.definedSizePixels = definedSize; 
canvasPosition(3) = definedSize(2);
canvasPosition(4) = definedSize(1);
set(handles.imageCanvas, 'Position', canvasPosition);
set(handles.imageCanvas, 'Units', currentAxesUnits);

subImage = IM(handles.imorigin(2):(handles.imorigin(2) + handles.definedSizePixels(1)-1), handles.imorigin(1):(handles.imorigin(1) + handles.definedSizePixels(2)-1));
handles.implot = image(im2uint8(subImage));

handles.definedSize = getObjectPosition(handles.imageCanvas, [3,4]);

handles.imorigin = [1,1];
handles.previousPosition = [-1,-1];
handles.previousCell = [-1,-1];
handles.isTracking = 0;
handles.cell_id = 1;
handles.highlightedCell = 1;
setappdata(handles.figure1, 'isEditing',  1);
setappdata(handles.figure1, 'selectedCell', -1);
setappdata(handles.figure1, 'xloc', uint16(size(subImage,2)/2));
setappdata(handles.figure1, 'yloc', uint16(size(subImage,2)/2));

guidata(hObject, handles);

set(handles.implot, 'ButtonDownFcn', {@imageCanvas_ButtonDownFcn, handles});
%set(handles.axisH, 'ButtonDownFcn', {@imageCanvas_ButtonDownFcn, handles});
%set(handles.axisV, 'ButtonDownFcn', {@imageCanvas_ButtonDownFcn, handles});

set(gca, 'xlimmode','manual',...
    'ylimmode','manual',...
    'zlimmode','manual',...
    'climmode','manual',...
    'alimmode','manual');

set(handles.currentFilenameLabel, 'String', handles.imageFilenames{1});
set(handles.movieSlider, 'Value', 0);
set(handles.currentFrameText, 'String', '1');
set(handles.frameProgressionLabel, 'String', ['1/' num2str(length(handles.imageFilenames))]);
set(handles.movieSlider, 'Enable', 'on');
set(handles.startStopTrackToogleButton, 'Value', 0);

if(get(handles.preprocessCheckbox, 'Value'))
    for i=1:length(handles.imageFilenames)
        handles.annotationLayers.localMaximaLayer(i).point = getImageMaxima(handles.imageSequence(:,:,i));
    end
end

handles.lh = addlistener(handles.movieSlider, 'ContinuousValueChange', @(source, event) imageCanvas_setImage(handles, getSliderIndex(handles)));
guidata(hObject, handles);

organizeLayout(handles)
imageCanvas_setImage(handles, 1);

function organizeLayout(handles)
verticalOffset = 1;
changeObjectPosition(handles.progressBarFigure, 1:3, [verticalOffset,verticalOffset,30]);
setObjectPosition(handles.progressBarLabel, [getObjectPosition(handles.progressBarFigure, 3) + 2, verticalOffset + 0.5]);
verticalOffset = 3;
setObjectPosition(handles.lowerLeftPanel, [0,verticalOffset]);
setObjectPosition(handles.lowerRightPanel, [handles.definedSize(1)-getObjectPosition(handles.lowerRightPanel,3),verticalOffset]);
verticalOffset = verticalOffset + getObjectPosition(handles.lowerLeftPanel, 4);
setObjectPosition(handles.movieSlider, [0,verticalOffset]);
changeObjectPosition(handles.movieSlider, 3, handles.definedSize(1));
verticalOffset = verticalOffset + getObjectPosition(handles.movieSlider, 4);
setObjectPosition(handles.imageCanvas, [0, verticalOffset]);
verticalOffset = verticalOffset + getObjectPosition(handles.imageCanvas, 4);
setObjectPosition(handles.currentFilenameLabel, [0, verticalOffset]);
setObjectPosition(handles.frameProgressionLabel, [handles.definedSize(1)-getObjectPosition(handles.frameProgressionLabel,3), verticalOffset]);
totalFigureSize = [handles.definedSize(1) + getObjectPosition(handles.annotationPannel,3), verticalOffset + getObjectPosition(handles.currentFilenameLabel, 4)];
verticalOffset = verticalOffset - getObjectPosition(handles.loadDatasetPanel, 4);
setObjectPosition(handles.loadDatasetPanel, [handles.definedSize(1), verticalOffset]);
verticalOffset = verticalOffset - getObjectPosition(handles.annotationPannel, 4);
setObjectPosition(handles.annotationPannel, [handles.definedSize(1), verticalOffset]);
changeObjectPosition(handles.figure1, [3:4], totalFigureSize);

function [imageFilenames, imageTimepoint, dataLength] = generateImageSequence(handles)
selectedGroup = getCurrentPopupString(handles.imageGroupSelection);
selectedChannel = getCurrentPopupString(handles.channelToogleSelection);
selectedPosition = getCurrentPopupString(handles.stagePositionSelection);
imageGroups = handles.database.group_label;
channels = handles.database.channel_name;
stagePositions = handles.database.position_number;

currentDatasetIdx = strcmp(imageGroups, selectedGroup) & stagePositions == str2double(selectedPosition);
if(iscell(channels))
    currentFileSequenceIdx = currentDatasetIdx & strcmp(selectedChannel, channels);
else
    currentFileSequenceIdx = currentDatasetIdx & channels == str2double(selectedChannel);
end
imageFilenames = handles.database.filename;
[imageTimepoint, imageOrdering] = sort(handles.database.timepoint(currentFileSequenceIdx));
currentFileSequenceIdx = find(currentFileSequenceIdx);
currentFileSequenceIdx = currentFileSequenceIdx(imageOrdering);

% Speeding up for test, load subset of images
%currentFileSequenceIdx = currentFileSequenceIdx(1:20);

imageFilenames = imageFilenames(currentFileSequenceIdx);
dataLength = max(unique(handles.database.timepoint(currentDatasetIdx)));
stepSize = 1/(length(imageFilenames)-1);
set(handles.movieSlider, 'SliderStep', [stepSize, stepSize]);

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


% --- Executes on button press in drawRadioButton.
function drawRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to drawRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of drawRadioButton


% --- Executes on button press in eraseRadioButton.
function eraseRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to eraseRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of eraseRadioButton


% --- Executes on button press in mergeRadioButton.
function mergeRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to mergeRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mergeRadioButton


% --- Executes on button press in separateRadioButton.
function separateRadioButton_Callback(hObject, eventdata, handles)
% hObject    handle to separateRadioButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of separateRadioButton


% --- Executes on selection change in annotationLayerSelection.
function annotationLayerSelection_Callback(hObject, eventdata, handles)
% hObject    handle to annotationLayerSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns annotationLayerSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from annotationLayerSelection


% --- Executes during object creation, after setting all properties.
function annotationLayerSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to annotationLayerSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in channelToogleSelection.
function channelToogleSelection_Callback(hObject, eventdata, handles)
%set(handles.channelSelection, 'Value', get(handles.channelToogleSelection, 'Value'));
handles.selectedChannel = getCurrentPopupString(handles.channelToogleSelection);
guidata(hObject, handles);
currentTimepoint = handles.imageTimepoints(getSliderIndex(handles));
[handles.imageFilenames, handles.imageTimepoints, handles.dataLength] = generateImageSequence(handles);
[~,newIndex] = min(abs(handles.imageTimepoints - currentTimepoint));
newIndex = newIndex(1);
guidata(hObject, handles);
imageCanvas_setImage(handles, newIndex);

% --- Executes during object creation, after setting all properties.
function channelToogleSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channelToogleSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in startStopTrackToogleButton.
function startStopTrackToogleButton_Callback(hObject, eventdata, handles)
% hObject    handle to startStopTrackToogleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of startStopTrackToogleButton
handles.isTracking = ~handles.isTracking;
if(get(handles.startStopTrackToogleButton, 'Value'))
    setappdata(handles.figure1, 'trackingStartPoint', 1);
else
    handles.previousCell = [-1,-1];
end
guidata(hObject, handles);

function position = getObjectPosition(hObject, index)
position = get(hObject, 'Position');
position = position(index);

function setObjectPosition(hObject, coordinates)
changeObjectPosition(hObject, 1:2, coordinates)

function changeObjectPosition(hObject, targetCoordinates, replacementCoordinates)
position = get(hObject, 'Position');
position(targetCoordinates) = replacementCoordinates;
set(hObject, 'Position', position);


% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if(strcmp(eventdata.Key, 'shift'))
    handles.imageScanningMode = 1;
    if(handles.isInsideCanvas)
        set(handles.figure1, 'Pointer', 'crosshair');
    end
end
if(strcmp(eventdata.Key,'control'))
    setappdata(handles.figure1, 'isEditing',  ~getappdata(handles.figure1, 'isEditing'));
    if(handles.isInsideCanvas && getappdata(handles.figure1, 'isEditing'))
        set(handles.figure1, 'Pointer', 'hand');
    else
        set(handles.figure1, 'Pointer', 'arrow');
    end
end
if(strcmp(eventdata.Key,'backspace'))
    currentFrame = str2double(get(handles.currentFrameText, 'String'));
    currentTimepoint = handles.imageTimepoints(currentFrame);
    if(handles.highlightedCell)
        if(get(handles.divisionToogleButton, 'Value'))
            handles.annotationLayers.divisionLayer(currentTimepoint).point(handles.highlightedCell,:) = [0,0];
        else
            for i=1:currentTimepoint
                handles.annotationLayers.pointLayer(i).point(handles.highlightedCell,:) = [0,0];
                handles.annotationLayers.divisionLayer(i).point(handles.highlightedCell,:) = [0,0];
            end
        end
    end
end
imageCanvas_refreshImage(handles);
guidata(hObject, handles);


% --- Executes on key release with focus on figure1 or any of its controls.
function figure1_WindowKeyReleaseFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was released, in lower case
%	Character: character interpretation of the key(s) that was released
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) released
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(eventdata.Key,'shift'))
    handles.imageScanningMode = 0;
    handles.previousPosition = [-1,-1];
    set(handles.figure1, 'Pointer', 'arrow');
end
% if(strcmp(eventdata.Key,'control'))
%     setappdata(handles.figure1, 'isEditing', 0);
%     set(handles.figure1, 'Pointer', 'arrow');
% end
guidata(hObject, handles);


% --- Executes on selection change in channelSelection.
function channelSelection_Callback(hObject, eventdata, handles)
% hObject    handle to channelSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channelSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channelSelection

% --- Executes on mouse press over figure background.
function imageCanvas_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = guidata(handles.figure1);
if(strcmp(get(handles.movieSlider, 'Enable'), 'off') || handles.imageScanningMode)
    return;
end
currentPoint = get(handles.figure1, 'CurrentPoint');
imageCanvasPosition = get(handles.imageCanvas, 'Position');
if(isInsideCoordinates(currentPoint, imageCanvasPosition))
    transformedPoint = getTransformedLocation(currentPoint, imageCanvasPosition, handles.imageCanvas);
    currentAbsolutePoint = transformedPoint + double(handles.imorigin) - 1; % Sensitive to image scaling
    currentFrame = str2double(get(handles.currentFrameText, 'String'));
    % TRACK PROPAGATION ALGORITHM
    if(get(handles.startStopTrackToogleButton, 'Value') && ~getappdata(handles.figure1, 'isEditing'))
        referencePoint = currentAbsolutePoint;        
        % Look for existing cell track, usefull for editing tracks,
        % only check once, when the user has clicked the startStop button
        if(getappdata(handles.figure1, 'trackingStartPoint'))
            handles.cell_id = defineCellId(handles);
            handles.highlightedCell = handles.cell_id;
            fprintf('new cell!\n');
            guidata(hObject, handles);
            setappdata(handles.figure1, 'trackingStartPoint', 0);
        else
            handles.cell_id = handles.highlightedCell;
        end
        if(get(handles.preprocessCheckbox, 'Value'))
            selectedPoint = getClosestCentroid(handles.annotationLayers.localMaximaLayer(currentFrame).point, currentAbsolutePoint, 15);
        else
            selectedPoint = currentAbsolutePoint;
        end
        handles.annotationLayers.pointLayer(currentFrame).point(handles.cell_id,:) = selectedPoint;
        handles.annotationLayers.pointLayer(currentFrame).value(handles.cell_id) = 1;
        if(get(handles.divisionToogleButton, 'Value'))
            handles.annotationLayers.divisionLayer(currentFrame).point(handles.cell_id,:) = selectedPoint;
        end
        frameSkip = 1;
        if(get(handles.trackingModeCheckbox, 'Value'))
            frameSkip = -abs(frameSkip);
        else
            frameSkip = abs(frameSkip);
        end
        
%         if(currentFrame + abs(frameSkip) <= length(handles.imageFilenames))
%             if(handles.annotationLayers.pointLayer(currentFrame + abs(frameSkip)).point(handles.cell_id,1) > 0)
%                 currentFrameCentroid = handles.annotationLayers.pointLayer(currentFrame).point(handles.cell_id,:);
%                 interpolatedCentroid = handles.annotationLayers.pointLayer(currentFrame + abs(frameSkip)).point(handles.cell_id,:);
%                 for i=1:(abs(frameSkip) - 1)
%                     if(~handles.annotationLayers.pointLayer(currentFrame + i).value(handles.cell_id))
%                         handles.annotationLayers.pointLayer(currentFrame + i).point(handles.cell_id,:) = currentFrameCentroid + round(abs(currentFrameCentroid - interpolatedCentroid) * i / (abs(frameSkip)-1));
%                     end
%                 end
%             end
%         end
        if(currentFrame - abs(frameSkip) > 0)
            if(handles.annotationLayers.pointLayer(currentFrame - abs(frameSkip)).point(handles.cell_id,1) > 0)
                currentFrameCentroid = handles.annotationLayers.pointLayer(currentFrame).point(handles.cell_id,:);
                interpolatedCentroid = handles.annotationLayers.pointLayer(currentFrame - abs(frameSkip)).point(handles.cell_id,:);
                for i=1:(abs(frameSkip) - 1)
                    if(~handles.annotationLayers.pointLayer(currentFrame - i).value(handles.cell_id))
                        handles.annotationLayers.pointLayer(currentFrame - i).point(handles.cell_id,:) = currentFrameCentroid + round(abs(currentFrameCentroid - interpolatedCentroid) * i / (abs(frameSkip)-1));
                    end
                end
            end
        end
        guidata(hObject, handles);
        imageCanvas_refreshImage(handles);
        drawnow;
        nextFrame = min(max(currentFrame + frameSkip, 1), length(handles.imageFilenames));
        imageCanvas_setImage(handles, nextFrame);
%         IM = double(getappdata(handles.figure1, 'IM'));
%         IM = IM - mean(IM(:));
%         referencePoint = currentAbsolutePoint;
%         while(currentFrame <= handles.imageTimepoints(length(handles.imageTimepoints))-1)
%             extent = 25;
%             subsettingRectangle = [max(1,referencePoint(1)-extent), max(1,referencePoint(2)-extent), min(handles.totalSize(2), referencePoint(1)+extent), min(handles.totalSize(2), referencePoint(2)+extent)];
%             sampleMask = IM(subsettingRectangle(2):subsettingRectangle(4), subsettingRectangle(1):subsettingRectangle(3));
%             
%             guidata(hObject, handles);
%             
%             imageCanvas_setImage(handles, currentFrame + frameSkip);
%             currentFrame = currentFrame + frameSkip;
%             
%             IM = getappdata(handles.figure1, 'IM');
%             IM = IM - mean(IM(:));
%             crosscorrelation = xcorr2(double(IM), double(sampleMask));
%             %crosscorrelation = imfilter(crosscorrelation, fspecial('gaussian', 10, 4), 'replicate');
%             [maxvalue, maxloc] = max(crosscorrelation(:));
%             [i,j] = ind2sub(size(crosscorrelation), maxloc);
%             i = i - (size(sampleMask,2) - 1)/2;
%             j = j - (size(sampleMask,1) - 1)/2;
%             
%             fprintf('%d,%d\t%d,%d\tDistance: %.2f\n', currentAbsolutePoint(1), currentAbsolutePoint(2), i, j, sqrt(sum((currentAbsolutePoint - [j,i]).^2)));            
%             if(sqrt(sum((currentAbsolutePoint - [j,i]).^2)) < 100)
%                 referencePoint = [j,i];
%                 handles.annotationLayers.pointLayer(currentFrame).point(handles.cell_id,:) = referencePoint;
%                 
%                 drawnow;
%             else
%                 break;
%             end
%             
%         end
        
    end
    if(get(handles.divisionToogleButton, 'Value'))
        %Do something
    end
    imageCanvas_refreshImage(handles);
end

function point = getClosestCentroid(reference, query, distanceThreshold)
if(~isempty(reference))
    distances = sqrt(sum((repmat(fliplr(query), size(reference,1), 1) - reference) .^ 2,2));
    [minValue, minLoc] = min(distances);
    if(minValue < distanceThreshold)
        point = [reference(minLoc,2),reference(minLoc,1)];
    else
        point = query;
    end
end

function [cell_id] = defineCellId(handles)
currentTime = handles.imageTimepoints(str2double(get(handles.currentFrameText, 'String')));
trackedCentroids = handles.annotationLayers.pointLayer(currentTime).point;
trackedCentroidsId = find(trackedCentroids(:,1) > 0);
max_cell_id = 1;
for i=1:length(handles.annotationLayers.pointLayer)
    max_entry = find(handles.annotationLayers.pointLayer(i).point(:,1) > 0, 1, 'last');
    if(~isempty(max_entry))
        max_cell_id = max(max_cell_id, max_entry);
    end
end
cell_id = max_cell_id + 1;
fprintf('Number of single tracks: %d\t Current Cell: %d\n', length(trackedCentroidsId), cell_id);

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in segmentButton.
function segmentButton_Callback(hObject, eventdata, handles)
% hObject    handle to segmentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in preprocessCheckbox.
function preprocessCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to preprocessCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of preprocessCheckbox


% --- Executes on scroll wheel click while the figure is in focus.
function figure1_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
if(strcmp(get(handles.movieSlider, 'Enable'), 'off') || handles.imageScanningMode)
    return;
end
currentIndex = str2double(get(handles.currentFrameText, 'String'));
nextIndex = min(max(currentIndex + eventdata.VerticalScrollCount,1),length(handles.imageFilenames));
imageCanvas_setImage(handles, nextIndex);
drawnow;

% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in saveAnnotationsButton.
function saveAnnotationsButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAnnotationsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
singleCellTracks = handles.annotationLayers;
selectedGroup = handles.selectedGroup;
selectedPosition = handles.selectedPosition;
databaseFile = handles.databaseFile;
sourcePath = handles.sourcePath;
uisave({'singleCellTracks','selectedGroup','selectedPosition','databaseFile','sourcePath'},fullfile(sourcePath, 'tracking.mat'));


% --- Executes on button press in centerButton.
function centerButton_Callback(hObject, eventdata, handles)
% hObject    handle to centerButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in pauseTrackButton.
function pauseTrackButton_Callback(hObject, eventdata, handles)
% hObject    handle to pauseTrackButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in loadAnnotationButton.
function loadAnnotationButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadAnnotationButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[databaseFile, sourcePath] = uigetfile(fullfile(handles.sourcePath, '*.mat'));
load(fullfile(sourcePath, databaseFile));
handles.annotationLayers = singleCellTracks;
handles.cell_id = 1;
if(~isfield(handles.annotationLayers, 'divisionLayer'))
    maxPointsPerImage = 10000;
    handles.annotationLayers.divisionLayer = repmat(struct('point', zeros(maxPointsPerImage,2),'cell_id', zeros(maxPointsPerImage,1)), handles.dataLength, 1);
end
guidata(hObject, handles);
imageCanvas_refreshImage(handles);

% --- Executes on button press in quickndirtyMode.
function quickndirtyMode_Callback(hObject, eventdata, handles)
% hObject    handle to quickndirtyMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of quickndirtyMode

% --- Executes on button press in propagateMode.
function propagateMode_Callback(hObject, eventdata, handles)
% hObject    handle to propagateMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of propagateMode


% --- Executes on button press in divisionToogleButton.
function divisionToogleButton_Callback(hObject, eventdata, handles)
% hObject    handle to divisionToogleButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of divisionToogleButton


% --- Executes on button press in trackingModeCheckbox.
function trackingModeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to trackingModeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of trackingModeCheckbox



function canvasWidthText_Callback(hObject, eventdata, handles)
% hObject    handle to canvasWidthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of canvasWidthText as text
%        str2double(get(hObject,'String')) returns contents of canvasWidthText as a double


% --- Executes during object creation, after setting all properties.
function canvasWidthText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to canvasWidthText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function canvasHeightText_Callback(hObject, eventdata, handles)
% hObject    handle to canvasHeightText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of canvasHeightText as text
%        str2double(get(hObject,'String')) returns contents of canvasHeightText as a double


% --- Executes during object creation, after setting all properties.
function canvasHeightText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to canvasHeightText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setCanvasSizeButton.
function setCanvasSizeButton_Callback(hObject, eventdata, handles)
% hObject    handle to setCanvasSizeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
newHeight = max(min(handles.maxHeight, str2double(get(handles.canvasHeightText, 'String'))), handles.minHeight);
newWidth = max(min(handles.maxWidth, str2double(get(handles.canvasWidthText, 'String'))), handles.minWidth);

handles.canvasSize = [newHeight, newWidth];
currentAxesUnits = get(handles.imageCanvas, 'Units');
set(handles.imageCanvas, 'Units', 'Pixels');
definedSize = [newHeight, newWidth];
handles.definedSizePixels = definedSize; 
changeObjectPosition(handles.imageCanvas, 3:4, definedSize([2,1]));
set(handles.imageCanvas, 'Units', currentAxesUnits);
handles.definedSize = getObjectPosition(handles.imageCanvas, [3:4]);

handles.imorigin = evaluateNewOrigin(handles, handles.imorigin);
guidata(hObject, handles);
setappdata(handles.figure1, 'xloc', 1);
setappdata(handles.figure1, 'yloc', 1);
subImage = prepareOverlayImage(handles);
handles.implot = image(subImage);
set(handles.implot, 'ButtonDownFcn', {@imageCanvas_ButtonDownFcn, handles});

organizeLayout(handles);
guidata(hObject, handles);



function filepathText_Callback(hObject, eventdata, handles)
% hObject    handle to filepathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filepathText as text
%        str2double(get(hObject,'String')) returns contents of filepathText as a double



function imResizeText_Callback(hObject, eventdata, handles)
% hObject    handle to imResizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of imResizeText as text
%        str2double(get(hObject,'String')) returns contents of imResizeText as a double


% --- Executes during object creation, after setting all properties.
function imResizeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imResizeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in highlightedCellPopupMenu.
function highlightedCellPopupMenu_Callback(hObject, eventdata, handles)
% hObject    handle to highlightedCellPopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns highlightedCellPopupMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from highlightedCellPopupMenu
handles.highlightedCell = str2double(getCurrentPopupString(handles.highlightedCellPopupMenu));
setappdata(handles.figure1, 'trackingStartPoint', 0);
guidata(hObject, handles);
imageCanvas_refreshImage(handles);

% --- Executes during object creation, after setting all properties.
function highlightedCellPopupMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to highlightedCellPopupMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
