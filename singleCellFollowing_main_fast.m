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

% Last Modified by GUIDE v2.5 20-Feb-2014 14:03:36

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

handles.maxWidth = 700;
handles.maxHeight = 550;
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

if(getappdata(handles.figure1, 'segmentationEdited'))
    imwrite(getappdata(handles.figure1, 'thresholdedImage'), fullfile(handles.segmentationFolder, getappdata(handles.figure1, 'segmentationFile')));
end
setappdata(handles.figure1, 'segmentationEdited', 0);

segmentationFile = regexprep(handles.imageFilenames{index}, '_w(\d+)\w+.*_s', '_s');
segmentationFile = regexprep(segmentationFile, '\.\w+', '\.PNG');
% if(strcmp(getCurrentPopupString(handles.channelToogleSelection), getCurrentPopupString(handles.channelSelection)))
%     % SPEED UP ATTEMPT: load image from preallocated array
%     IM = handles.imageSequence(:,:,index);
% else
%     IM = im2uint8(imnormalize(imread(fullfile(handles.rawdataFolder, handles.imageFilenames{index}))));
% end
    
IM = im2uint8(imnormalize(imread(fullfile(handles.rawdataFolder, handles.imageFilenames{index}))));
thresholdedImage = bwlabel(double(imread(fullfile(handles.segmentationFolder, segmentationFile))));

set(handles.currentFrameText, 'String', num2str(index));
set(handles.frameProgressionLabel, 'String', [num2str(index) '/' num2str(length(handles.imageFilenames))]);
set(handles.movieSlider, 'Value', getSliderValue(handles, index));
set(handles.currentFilenameLabel, 'string', handles.imageFilenames{index});
setappdata(handles.figure1, 'IM', IM);
setappdata(handles.figure1, 'thresholdedImage', thresholdedImage);
setappdata(handles.figure1, 'selectedCell', -1);
setappdata(handles.figure1, 'segmentationFile', segmentationFile);

subImage = prepareOverlayImage(handles);
set(handles.implot, 'CData', subImage);

% DISPLAY OPTION 2
%[subImage, highlightedImage, selectedImage] = prepareOverlayImage(handles);
%set(handles.implot, 'CData', subImage);
%set(handles.highlightLayer, 'AlphaData', highlightedImage);
%set(handles.selectionLayer, 'AlphaData', selectedImage);

if(~getappdata(handles.figure1, 'autoTracking'))
    disp('Hello');
    drawnow;
end

function handles = imageCanvas_refreshImage(handles)
handles = guidata(handles.figure1);
transformedPoint = [getappdata(handles.figure1, 'xloc'), getappdata(handles.figure1, 'yloc')];
subImage = prepareOverlayImage(handles);

% Generate an updated figure drawing the distinct layers
set(handles.implot, 'CData', subImage);
%set(handles.axisH, 'XData', [transformedPoint(1), transformedPoint(1)], 'YData', ylim);
%set(handles.axisV, 'YData', [transformedPoint(2), transformedPoint(2)], 'XData', xlim);

% DISPLAY OPTION 2
%[subImage, highlightedImage, selectedImage] = prepareOverlayImage(handles);
%set(handles.implot, 'CData', subImage);
%set(handles.highlightLayer, 'AlphaData', highlightedImage);
%set(handles.selectionLayer, 'AlphaData', selectedImage);

if(~getappdata(handles.figure1, 'autoTracking'))
    drawnow;
end

function [subImage] = prepareOverlayImage(handles)
currentTime = handles.imageTimepoints(str2double(get(handles.currentFrameText, 'String')));
IM = getappdata(handles.figure1, 'IM');
thresholdedImage = getappdata(handles.figure1, 'thresholdedImage');
transformedPoint = [getappdata(handles.figure1, 'xloc'), getappdata(handles.figure1, 'yloc')];
selectedCell = getappdata(handles.figure1, 'selectedCell');

trackedCentroids = handles.annotationLayers.pointLayer(currentTime).point(:,:);
trackedCentroids = trackedCentroids(trackedCentroids(:,1) > 0,:);
trackedCentroids = sub2ind(size(IM), trackedCentroids(:,2), trackedCentroids(:,1));
if(~isempty(trackedCentroids))
    trackedCellImage = imfill(bwperim(thresholdedImage), trackedCentroids);
    trackedCellImage = imdilate(trackedCellImage & ~bwperim(thresholdedImage), strel('disk',1));
else
    trackedCellImage = zeros(size(IM));
end

subsettingRectangle = {handles.imorigin(2):(handles.imorigin(2) + handles.definedSizePixels(1)-1), handles.imorigin(1):(handles.imorigin(1) + handles.definedSizePixels(2)-1)};
subImage = IM(subsettingRectangle{1}, subsettingRectangle{2});
thresholdedImage = thresholdedImage(subsettingRectangle{1}, subsettingRectangle{2});
trackedCellImage = trackedCellImage(subsettingRectangle{1}, subsettingRectangle{2});

% DISPLAY OPTION 0
% highglightedImage = bwperim(thresholdedImage);
% if(thresholdedImage(transformedPoint(2), transformedPoint(1)))
%     highglightedImage = highglightedImage | thresholdedImage == thresholdedImage(transformedPoint(2),transformedPoint(1));
% end
% subImage = imoverlay(imnormalize(subImage), highglightedImage, [0.3, 1, 0.3]);
% if(selectedCell > 0)
%     subImage = imoverlay(subImage, thresholdedImage == selectedCell, [1, 0.2, 0.3]);
% end
% if(handles.annotationLayers.pointLayer(currentTime).point(handles.cell_id,1))
%     cellularCentroid = handles.annotationLayers.pointLayer(currentTime).point(handles.cell_id,:);
%     trackedCell = thresholdedImage(cellularCentroid(2), cellularCentroid(1));
%     trackedCellImage = thresholdedImage == trackedCell;
%     subImage = imoverlay(subImage, trackedCellImage, [0.2, 0.8, 1]);
% end

% DISPLAY OPTION 1
subImage = imoverlay(im2rgb(subImage), bwperim(thresholdedImage), [0.3, 1, 0.3]);
if(thresholdedImage(transformedPoint(2), transformedPoint(1)))
    highlightedCell = thresholdedImage == thresholdedImage(transformedPoint(2),transformedPoint(1)) & thresholdedImage ~= selectedCell & thresholdedImage ~= trackedCellImage;
    greenMask = cat(3, ones(size(highlightedCell)) + highlightedCell * -0.5, ones(size(highlightedCell)) + highlightedCell * 1.3, ones(size(highlightedCell)) + highlightedCell * -0.5);
    subImage = im2uint8(imnormalize(subImage) .* greenMask);
end
if(selectedCell > 0)
    selectedCellImage = thresholdedImage == selectedCell & thresholdedImage ~= trackedCellImage;
    redMask = cat(3, ones(size(selectedCellImage)) + 1 * selectedCellImage, ones(size(selectedCellImage)) - 0.5 * selectedCellImage, ones(size(selectedCellImage)) - 0.7 * selectedCellImage);
    subImage = imnormalize(subImage) .* redMask;
    subImage = imoverlay(subImage, bwperim(selectedCellImage), [1, 0.2, 0.3]);
end
if(sum(sum(trackedCellImage)) > 0)
    cellularCentroid = handles.annotationLayers.pointLayer(currentTime).point(handles.cell_id,:);
    if(cellularCentroid(2) > 0)
        trackedCell = thresholdedImage == thresholdedImage(cellularCentroid(2), cellularCentroid(1));
    else
        trackedCell = zeros(size(thresholdedImage));
    end
    trackedCellImage = trackedCellImage & ~trackedCell;
    blueMask = cat(3, ones(size(trackedCellImage)) -0.5 * trackedCellImage, ones(size(trackedCellImage)) + 0.6 * trackedCellImage, ones(size(trackedCellImage)) + 2 * trackedCellImage);
    subImage = imnormalize(subImage) .* blueMask;
    subImage = imoverlay(subImage, bwperim(trackedCellImage), [0.2, 0.8, 1]);
    if(cellularCentroid(2) > 0)
        orangeMask = cat(3, ones(size(trackedCell)) + 2 * trackedCell, ones(size(trackedCell)) + 1.5 * trackedCell, ones(size(trackedCell)) -0.5 * trackedCell);
        subImage = imnormalize(subImage) .* orangeMask;
        subImage = imoverlay(subImage, bwperim(trackedCell), [0.9, 0.5, 0.2]);
    end
end

% DISPLAY OPTION 2
% highlightedImage = bwperim(thresholdedImage);
% if(thresholdedImage(transformedPoint(2), transformedPoint(1)))
%     highlightedCell = thresholdedImage == thresholdedImage(transformedPoint(2),transformedPoint(1)) & thresholdedImage ~= selectedCell;
%     highlightedImage(highlightedCell) = 1;
% end
% selectedImage = zeros(size(subImage));
% if(selectedCell > 0)
%     selectedImage = thresholdedImage == selectedCell;
% end

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
            handles.previousPosition = transformedPoint;
        end
    end
    imageCanvas_refreshImage(handles);
else
    set(handles.figure1, 'Pointer', 'arrow');
    handles.previousPosition = [-1,-1];
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
set(handles.stagePositionSelection, 'String', unique(positions));
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

IM = imread(fullfile(handles.rawdataFolder, handles.imageFilenames{1}));
handles.totalSize = size(IM);
% SPEED UP ATTEMPT: PREALLOCATE IMAGES
% handles.imageSequence = uint8(zeros(size(IM,1), size(IM,2), length(handles.imageFilenames)));
% set(handles.progressBar, 'Value', 0);
% set(handles.progressBar, 'Maximum', length(handles.imageFilenames));
% for i=1:length(handles.imageFilenames)
%     handles.imageSequence(:,:,i) = im2uint8(imnormalize(imread(fullfile(handles.rawdataFolder, handles.imageFilenames{i}))));
%     set(handles.progressBar, 'Value', i);
% end

maxPointsPerImage = 1000;
handles.annotationLayers.pointLayer = repmat(struct('n', 0, 'point', zeros(maxPointsPerImage,2), 'value', zeros(maxPointsPerImage,1), 'version', zeros(maxPointsPerImage,1)), handles.dataLength, 1);
handles.annotationLayers.trackLayer = repmat(struct('point', zeros(maxPointsPerImage,2), 'value', zeros(maxPointsPerImage,1), 'cell', zeros(maxPointsPerImage,1)), handles.dataLength, 1);

currentAxesUnits = get(handles.imageCanvas, 'Units');
set(handles.imageCanvas, 'Units', 'Pixels');
canvasPosition = get(handles.imageCanvas, 'Position');
handles.canvasSize = [canvasPosition(4), canvasPosition(3)];
definedSize = [min(size(IM,1), handles.maxHeight), min(size(IM,2), handles.maxWidth)]; 
handles.definedSizePixels = definedSize; 
canvasPosition(3) = definedSize(2);
canvasPosition(4) = definedSize(1);
set(handles.imageCanvas, 'Position', canvasPosition);
set(handles.imageCanvas, 'Units', currentAxesUnits);

subImage = IM(handles.imorigin(2):(handles.imorigin(2) + handles.definedSizePixels(1)-1), handles.imorigin(1):(handles.imorigin(1) + handles.definedSizePixels(2)-1));
handles.implot = image(im2uint8(subImage));
hold(handles.imageCanvas);
% DISPLAY OPTION 2
% greenMask = im2uint8(cat(3, ones(size(subImage))*0.3, ones(size(subImage))*1, ones(size(subImage))*0.3));
% handles.highlightLayer = image(greenMask);
% set(handles.highlightLayer, 'AlphaData', zeros(size(subImage)));
% hold(handles.imageCanvas);
% hold(handles.imageCanvas);
% redMask = im2uint8(cat(3, ones(size(subImage))*0.3, ones(size(subImage))*1, ones(size(subImage))*0.3));
% handles.selectionLayer = image(redMask);
% set(handles.selectionLayer, 'AlphaData', zeros(size(subImage)));

%handles.axisH = plot(xlim, [uint16(size(subImage,2)/2), uint16(size(subImage,2)/2)]);
%handles.axisV = plot([uint16(size(subImage,1)/2), uint16(size(subImage,1)/2)], ylim);
hold(handles.imageCanvas);

handles.definedSize = getObjectPosition(handles.imageCanvas, [3,4]);

handles.imorigin = [1,1];
handles.previousPosition = [-1,-1];
handles.previousCell = [-1,-1];
handles.isTracking = 0;
handles.cell_id = 1;
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

set(handles.progressBar, 'Value', 0);
set(handles.progressBar, 'Maximum', length(handles.imageFilenames));
segmentationFolder = fullfile(handles.sourcePath, 'SEGMENT_DATA');
if(~exist(segmentationFolder, 'dir'))
    mkdir(segmentationFolder);
end
handles.segmentationFolder = segmentationFolder;
for i=1:1:length(handles.imageFilenames)
    segmentationFile = regexprep(handles.imageFilenames{i}, '_w(\d+)\w+.*_s', '_s');
    segmentationFile = regexprep(segmentationFile, '\.\w+', '\.PNG', 'ignoreCase');
    if(~exist(fullfile(segmentationFolder, segmentationFile), 'file') || get(handles.preprocessCheckbox, 'Value'))
        %IM = imread(fullfile(handles.sourcePath, handles.selectedGroup, handles.imageFilenames{i}));
        IM = imread(fullfile(handles.rawdataFolder, handles.imageFilenames{i}));
        segmentedImage = singleCellFollowing_imageProcessing(IM);
        imwrite(uint16(segmentedImage), fullfile(segmentationFolder, segmentationFile));
    end
    set(handles.progressBar, 'Value', i);
    drawnow;
end
setappdata(handles.figure1, 'segmentationEdited', 0);

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
currentFileSequenceIdx = currentDatasetIdx & strcmp(selectedChannel, channels);
imageFilenames = handles.database.filename;
[imageTimepoint, imageOrdering] = sort(handles.database.timepoint(currentFileSequenceIdx));
currentFileSequenceIdx = find(currentFileSequenceIdx);
currentFileSequenceIdx = currentFileSequenceIdx(imageOrdering);
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
    handles.cell_id = handles.cell_id + 1;
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
    % If the user is in editing mode
    if(getappdata(handles.figure1, 'isEditing') && ~handles.imageScanningMode)
        thresholdedImage = getappdata(handles.figure1, 'thresholdedImage');
        selectedCell = thresholdedImage(currentAbsolutePoint(2), currentAbsolutePoint(1));
        % If the user touches the background, the algorithm will try to
        % find an object in the selected position
        if(~selectedCell)
            IM = getappdata(handles.figure1, 'IM');
            extend = 35;
            subRectangle = [currentAbsolutePoint(1) - extend, currentAbsolutePoint(2) - extend, currentAbsolutePoint(1) + extend, currentAbsolutePoint(2) + extend];
            subRectangle(1) = max(subRectangle(1),1);
            subRectangle(2) = max(subRectangle(2),1);
            subRectangle(3) = min(subRectangle(3),handles.totalSize(2));
            subRectangle(4) = min(subRectangle(4),handles.totalSize(1));
            subImage =IM(subRectangle(2):subRectangle(4), subRectangle(1):subRectangle(3));
            oldObject = thresholdedImage(subRectangle(2):subRectangle(4), subRectangle(1):subRectangle(3));
            BlurredImage =  imfilter(imnormalize(subImage), fspecial('gaussian', 15, 4), 'replicate');
            newObject = im2bw(BlurredImage, graythresh(BlurredImage(~oldObject))) & ~imdilate(oldObject, strel('disk', 1));
            newObject = imfill(newObject, 'holes');
            substituteImage = newObject * double(max(thresholdedImage(:)) + 1) + oldObject;
            thresholdedImage(subRectangle(2):subRectangle(4), subRectangle(1):subRectangle(3)) = substituteImage;
            setappdata(handles.figure1, 'segmentationEdited', 1);
            setappdata(handles.figure1, 'thresholdedImage', thresholdedImage);
        end
        setappdata(handles.figure1, 'selectedCell', selectedCell);
        setappdata(handles.figure1, 'sourcePoint', currentAbsolutePoint);
    end
    % If the user is tracking and not editing, propagate tracking from
    % current selected cell
    % TRACK PROPAGATION ALGORITHM
    if(get(handles.startStopTrackToogleButton, 'Value') && ~getappdata(handles.figure1, 'isEditing'))
        setappdata(handles.figure1, 'autoTracking', 0);
%         if(handles.previousCell(1) ~= -1)   % Sensitive to image scaling
%             displacement = [0,0];
%         else
%             displacement = currentAbsolutePoint - handles.previousCell;
%             displacement = [0,0];
%         end
%         handles.previousCell = currentAbsolutePoint;
%         handles.imorigin = evaluateNewOrigin(handles, handles.imorigin + displacement);
%         guidata(hObject, handles);
%         imageCanvas_setImage(handles, getSliderIndex(handles) + 1);
        thresholdedImage = getappdata(handles.figure1, 'thresholdedImage');
        referencePoint = currentAbsolutePoint;
        if(~thresholdedImage(currentAbsolutePoint(2),currentAbsolutePoint(1)))
            return;
        end
        foundCell = 1;
        while(foundCell)
            setappdata(handles.figure1, 'autoTracking', 1);
            currentTime = handles.imageTimepoints(str2double(get(handles.currentFrameText, 'String')));
            thresholdedImage = getappdata(handles.figure1, 'thresholdedImage');
            foundCell = 0;
            centroids = regionprops(thresholdedImage, 'Centroid');
            distance = cellfun(@(x) sqrt(sum((x-referencePoint).^2)), {centroids(:).Centroid});
            [sortedDistance, sortedIndex] = sort(distance);
            %fprintf('Closest two points: %.2f, %.2f\n', sortedDistance(1), sortedDistance(2));
            if(sortedDistance(1) < 20 && sortedDistance(2) > 10)
                cellularCentroid = round(centroids(sortedIndex(1)).Centroid);
                % Check if the new centroid is equal to the one that has
                % already been found (useful when connecting tracks)
                if(sum(cellularCentroid == handles.annotationLayers.pointLayer(currentTime).point(handles.cell_id,:)) == 2)
                    foundCell = 0;
                else
                    foundCell = 1;
                end
            end
            if(foundCell)
                handles.annotationLayers.pointLayer(currentTime).n = handles.annotationLayers.pointLayer(currentTime).n+1;
                handles.annotationLayers.pointLayer(currentTime).point(handles.cell_id,:) = cellularCentroid;
                %fprintf('Time: %d\tCell: %d\tValue: %d\tPoint: %d,%d\tReference: %d,%d\n', currentTime, handles.cell_id, thresholdedImage(cellularCentroid(2), cellularCentroid(1)), handles.annotationLayers.pointLayer(currentTime).point(handles.cell_id,1), handles.annotationLayers.pointLayer(currentTime).point(handles.cell_id,2),referencePoint(1),referencePoint(2));
                referencePoint = cellularCentroid;
                guidata(hObject, handles);
                imageCanvas_refreshImage(handles);
                drawnow;
                if(getSliderIndex(handles) > 1)
                    imageCanvas_setImage(handles, getSliderIndex(handles) - 1);
                end
            end
        end
        guidata(hObject, handles);
        setappdata(handles.figure1, 'autoTracking', 0);
    end
    imageCanvas_refreshImage(handles);
end

% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonUpFcn(hObject, eventdata, handles)
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
    if(getappdata(handles.figure1, 'isEditing'))
        thresholdedImage = getappdata(handles.figure1, 'thresholdedImage');
        %thresholdedImage = handles.thresholdedImage(:,:,currentFrame);
        Objects = thresholdedImage;
        selectedPoint2 = Objects(currentAbsolutePoint(2), currentAbsolutePoint(1));
        selectedPoint1 = getappdata(handles.figure1, 'selectedCell');
        % If the mouse was pressed and released in recognized object
        % positions
        if(selectedPoint1 > 0 && selectedPoint2 > 0)
            isolatedObjects = Objects == selectedPoint1 | Objects == selectedPoint2;
            [j,i] = ind2sub(size(Objects), find(isolatedObjects));
            isolatedObjectsModified = isolatedObjects(min(j):max(j),min(i):max(i));
            % If current selected cell is different from the previous one
            % the algorithm will try to merge these cells if they are
            % touching
            if(selectedPoint1 ~= selectedPoint2)
                isolatedObjectsBridged = bwmorph(isolatedObjectsModified, 'bridge');
                isolatedObjectsBridged = imfill(isolatedObjectsBridged, 'holes') * double(selectedPoint2);
                if(sum(logical(isolatedObjectsBridged(:)) ~= logical(isolatedObjectsModified(:))))
                    Objects(isolatedObjects) = 0;
                    Objects(min(j):max(j),min(i):max(i)) = double(Objects(min(j):max(j),min(i):max(i))) + isolatedObjectsBridged;
                    setappdata(handles.figure1, 'segmentationEdited', 1);
                end
            else
                % If the mouse is released within the same cell, the
                % algorithm will try to separe these.
                sourcePoint = getappdata(handles.figure1, 'sourcePoint');
                if(sqrt(sum((sourcePoint - currentAbsolutePoint) .^ 2)) > 5)
                    defaultMaxima1 = sourcePoint - [min(i),min(j)];
                    defaultMaxima2 = currentAbsolutePoint - [min(i),min(j)];
                    IM = getappdata(handles.figure1, 'IM');
                    IM = IM(min(j):max(j),min(i):max(i));
                    IM(~isolatedObjectsModified) = 0;
                    BlurredImage = imfilter(IM, fspecial('gaussian', 15, 4), 'replicate');
                    BlurredImage = bwdist(isolatedObjectsModified);
                    %localMaxima = imregionalmax(BlurredImage);
                    %[a,b] = ind2sub(size(localMaxima), find(localMaxima));
                    %[~, maxima1] = min((a-defaultMaxima1(1)).^2 + (b-defaultMaxima1(2)).^2);
                    %[~, maxima2] = min((a-defaultMaxima2(1)).^2 + (b-defaultMaxima2(2)).^2);
                    %if(maxima1 ~= maxima2)
                    %    maximaPair = sub2ind(size(localMaxima), a([maxima1, maxima2]),b([maxima1, maxima2]));
                    %else
                        maximaPair = sub2ind(size(BlurredImage),[defaultMaxima1(2),defaultMaxima2(2)],[defaultMaxima1(1),defaultMaxima2(1)]);
                    %end
                    localMaxima = zeros(size(BlurredImage));
                    localMaxima(maximaPair) = 1;
                    segmented = double(watershed(imimposemin(-BlurredImage, localMaxima))) .* double(isolatedObjectsModified);
                    segmented = bwlabel(logical(segmented)) + double(max(max(thresholdedImage))) * logical(segmented);
                    Objects(isolatedObjects) = 0;
                    Objects(min(j):max(j),min(i):max(i)) = double(Objects(min(j):max(j),min(i):max(i))) + segmented;
                    setappdata(handles.figure1, 'segmentationEdited', 1);
                end
            end
            %handles.thresholdedImage(:,:,currentFrame) = Objects;
            setappdata(handles.figure1, 'thresholdedImage', Objects);
            setappdata(handles.figure1, 'selectedCell', selectedPoint2);
            imageCanvas_refreshImage(handles);
        end
    end
end

% --- Executes on button press in segmentButton.
function segmentButton_Callback(hObject, eventdata, handles)
% hObject    handle to segmentButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IM = getappdata(handles.figure1, 'IM');
segmentedImage = singleCellFollowing_imageProcessing(IM);
setappdata(handles.figure1, 'thresholdedImage', segmentedImage);
imageCanvas_refreshImage(handles);
setappdata(handles.figure1, 'segmentationEdited', 1);


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
nextIndex = min(max(currentIndex + eventdata.VerticalScrollCount,1),handles.dataLength);
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