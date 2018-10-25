%% p53Cinema_singleCellAnnotation_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53Cinema_singleCellAnnotation_gui_imageViewer(master, maxHeight)
%% Create the figure
maxHeight = maxHeight - 10*master.ppChar(2);

hheightaxes = max(min(master.obj_imageViewer.image_height, maxHeight), 400);
hwidthaxes = hheightaxes * master.obj_imageViewer.image_width / master.obj_imageViewer.image_height;
hheightaxes = hheightaxes/master.ppChar(2);
hwidthaxes = hwidthaxes/master.ppChar(1);

fwidth = hwidthaxes;
fheight = hheightaxes + 5;

f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Resize','off','Name','Image Viewer',...
    'Renderer','OpenGL','Position',[0 0 fwidth fheight],...
    'CloseRequestFcn',{@fCloseRequestFcn},...
    'KeyPressFcn',{@fKeyPressFcn},...
    'WindowButtonDownFcn',{@fWindowButtonDownFcn},...
    'WindowButtonMotionFcn',{@fHover},...
    'WindowScrollWheelFcn',{@fWindowScrollWheelFcn});

figurePosition = get(gcf, 'Position');

hx = 0; hy = figurePosition(4) - hheightaxes;

%hwidth = master.obj_imageViewer.image_width/master.ppChar(1);
%hheight = master.obj_imageViewer.image_height/master.ppChar(2);
%hx = (fwidth-hwidth)/2;
%hy = (fheight-hheight-100/master.ppChar(2))/2+100/master.ppChar(2);
haxesImageViewer = axes('Units','characters','DrawMode','fast','XTick',[], 'YTick', [],...
    'Position',[hx hy hwidthaxes  hheightaxes ],'YDir','reverse','Visible','on',...
    'XLim',[1-0.5,master.obj_imageViewer.image_width+0.5],'YLim',[1-0.5,master.obj_imageViewer.image_height+0.5]); %when displaying images the center of the pixels are located at the position on the axis. Therefore, the limits must account for the half pixel border.
%% Create an axes
% highlighted cell with hover haxesHighlight =
% axes('Units','characters','DrawMode','fast','color','none',...
%     'Position',[hx hy hwidth hheight],...
%     'XLim',[1,master.image_width],'YLim',[1,master.image_height]);
cmapHighlight = colormap(haxesImageViewer,jet(16)); %63 matches the number of elements in ang
%% object order
% # image
% # annotation layer
% # highlight
% # selected cell
colormap(haxesImageViewer,gray(255));
sourceImage = image('Parent',haxesImageViewer,'CData',master.obj_imageViewer.currentImage);
hold(haxesImageViewer, 'on');

trackedCellsPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',10,...
    'Marker','o','MarkerEdgeColor',[0,0.75,1],'MarkerFaceColor',[0,0.25,1],...
    'Parent',haxesImageViewer,'LineSmoothing', 'off');

selectedCellPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',10,...
    'Marker','o','MarkerEdgeColor',[1,0.75,0],'MarkerFaceColor',[1,0,0],...
    'Parent',haxesImageViewer,'LineSmoothing', 'off');

cellsInRangePatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',1,...
    'Marker','o','MarkerEdgeColor',[1,0.75,0],'MarkerFaceColor',[1,0,0],...
    'Parent',haxesImageViewer,'LineSmoothing', 'off');

closestCellPatch = patch('XData',[],'YData',[],...
    'EdgeColor','none','FaceColor','none','MarkerSize',5,...
    'Marker','o','MarkerEdgeColor',[0,0.75,0.24],'MarkerFaceColor',[0,1,0],...
    'Parent',haxesImageViewer,'LineSmoothing', 'off');
hold(haxesImageViewer, 'off');

%% Create controls
% Slider bar and two buttons
hwidth = 50/master.ppChar(1);
hheight = 20/master.ppChar(2);
hx = 0;
hy = 0;

sliderStep = 1/(master.obj_fileManager.numImages - 1);
hsliderExploreStack = uicontrol('Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[255 215 0]/255,...
    'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hwidth, hy, fwidth-(hwidth*2), hheight],...
    'Callback',{@sliderExploreStack_Callback});
try    % R2013b and older
    addlistener(hsliderExploreStack,'ActionEvent',@sliderExploreStack_Callback);
catch  % R2014a and newer
    addlistener(hsliderExploreStack,'ContinuousValueChange',@sliderExploreStack_Callback);
end

hpushbuttonFirstImage = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','BackgroundColor',[255 215 0]/255,...
    'String','First Image','Position',[hx hy hwidth hheight],...
    'Callback',{@pushbuttonFirstImage_Callback});

hx = hwidthaxes - hwidth;
hpushbuttonLastImage = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','BackgroundColor',[60 179 113]/255,...
    'String','Last Image','Position',[hx hy hwidth hheight],...
    'Callback',{@pushbuttonLastImage_Callback});

hx = 0;
hy = hheight;

htextMarkerSize = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial',...
    'String','Marker size','Position',[hx hy hwidth hheight]);
hx = hwidth;
hpopupMarkerSize = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Select channel','Position',[hx, hy, hwidth*1.5, hheight],...
    'Enable', 'on', 'parent',f, 'Callback',{@popupMarkerSize_Callback});
set(hpopupMarkerSize, 'String', {'Large', 'Medium', 'Small'});
set(hpopupMarkerSize, 'Value', 1);

hx = hx + hwidth*1.5;
htextFrameNumber = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','center',...
    'String','Frame 1','Position',[hx, hy, hwidth*2, hheight],...
    'parent',f);
hx = hx + hwidth*2;
hpopupViewerChannel = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Select channel','Position',[hx, hy, hwidth * 1.5, hheight],...
    'Enable', 'on', 'parent',f, 'Callback',{@popupViewerChannel_Callback});
fileManagerHandles = guidata(master.obj_fileManager.gui_fileManager);
set(hpopupViewerChannel, 'String', get(fileManagerHandles.hpopupPrimaryChannel, 'String'));
set(hpopupViewerChannel, 'Value', get(fileManagerHandles.hpopupPrimaryChannel, 'Value'));
hx = hx + hwidth*1.5;
hcheckboxPreprocessFrame = uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Preprocess','Position',[hx, hy, hwidth*1.5, hheight],...
    'Value',0,'parent',f, 'Callback',{@checkboxPreprocessFrame_Callback});

%%
% store the uicontrol handles in the figure handles via guidata()
handles.axesImageViewer = haxesImageViewer;

handles.pushbuttonFirstImage = hpushbuttonFirstImage;
handles.pushbuttonLastImage = hpushbuttonLastImage;
handles.hsliderExploreStack = hsliderExploreStack;
handles.cmapHighlight = cmapHighlight;

handles.trackedCellsPatch = trackedCellsPatch;
handles.selectedCellPatch = selectedCellPatch;
handles.cellsInRangePatch = cellsInRangePatch;
handles.closestCellPatch = closestCellPatch;

handles.sourceImage = sourceImage;
handles.hpopupViewerChannel = hpopupViewerChannel;
handles.htextFrameNumber = htextFrameNumber;
handles.hcheckboxPreprocessFrame = hcheckboxPreprocessFrame;

guidata(f,handles);
%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
%%
%
    function fCloseRequestFcn(~,~)
        %do nothing. This means only the master object can close this
        %window.
    end
%%
%
    function fKeyPressFcn(~,keyInfo)
        switch keyInfo.Key
            case 'period'
                master.obj_imageViewer.nextFrame;
            case 'comma'
                master.obj_imageViewer.previousFrame;
            case 'rightarrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_featureTracker.centroidsFeatures);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints > master.obj_imageViewer.currentFrame,1,'first');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'leftarrow'
                breakpoints = getTrackBreakpoints(master.obj_imageViewer.obj_featureTracker.centroidsFeatures);
                if(~isempty(breakpoints))
                    jumpFrame = find(breakpoints < master.obj_imageViewer.currentFrame,1,'last');
                    if(~isempty(jumpFrame))
                        master.obj_imageViewer.setFrame(breakpoints(jumpFrame));
                    end
                end
            case 'shift'
                master.obj_imageViewer.obj_featureTracker.setAddMode;
            case 'control'
                master.obj_imageViewer.obj_featureTracker.setDeleteMode;
            case 'space'
                master.obj_imageViewer.obj_featureTracker.editAnnotation('left');
        end
    end

    function breakpoints = getTrackBreakpoints(centroidsObject)
        currentImageTimepoints = master.obj_fileManager.currentImageTimepoints;
        numCellsAnnotated = length(currentImageTimepoints);
        for i=1:length(currentImageTimepoints)
            currentTrack = centroidsObject.getCentroids(currentImageTimepoints(i));
            numCellsAnnotated(i) = size(currentTrack,1);
        end
        activeTimepoints = find(numCellsAnnotated > 0);
        if(~isempty(activeTimepoints))
            breakpoints = unique([1, find(diff(activeTimepoints) > 1)'+1, length(activeTimepoints)]);
            breakpoints = activeTimepoints(breakpoints);
        else
            breakpoints = [];
        end
    end

%%
%
    function fWindowButtonDownFcn(~,~)
        master.obj_imageViewer.obj_featureTracker.editAnnotation(get(master.obj_imageViewer.gui_imageViewer,'SelectionType'));
    end

    function fWindowScrollWheelFcn(~,event)
        newFrame = master.obj_imageViewer.currentFrame + event.VerticalScrollCount;
        master.obj_imageViewer.setFrame(newFrame);
    end
%%
% Translate the mouse position into the pixel location in the source image
    function fHover(~,~)
        set(f, 'HandleVisibility', 'on');
        set(0, 'currentfigure', f);
        % This function is redundant with the setImage function
        currentPoint = master.obj_imageViewer.getPixelxy;
        if(isempty(currentPoint))
            return;
        end
%         
%         if(~master.obj_fileManager.preprocessMode)
%             return;
%         end
        master.obj_imageViewer.setImage;
    end
%%
%
    function sliderExploreStack_Callback(~,~)
        frame = get(hsliderExploreStack,'Value');
        sliderStep = get(hsliderExploreStack,'SliderStep');
        targetFrame = round((frame / sliderStep(1)) + 1);
        master.obj_imageViewer.setFrame(targetFrame);
    end
%%
%
    function pushbuttonFirstImage_Callback(~,~)
        master.obj_imageViewer.setFrame(1);
    end
%%
%
    function pushbuttonLastImage_Callback(~,~)
        master.obj_imageViewer.setFrame(length(master.obj_fileManager.currentImageFilenames));
    end

%%
%
    function popupMarkerSize_Callback(~,~)
        markerSizeMap = [20, 10, 5; 10, 5, 3; 8, 3, 2];
        sizeOption = get(hpopupMarkerSize, 'Value');
        set(trackedCellsPatch, 'MarkerSize', markerSizeMap(sizeOption, 2));
        set(selectedCellPatch, 'MarkerSize', markerSizeMap(sizeOption, 2));
        set(closestCellPatch, 'MarkerSize', markerSizeMap(sizeOption, 3));
        
    end

%%
%
    function popupViewerChannel_Callback(~,~)
        master.obj_imageViewer.setFrame(master.obj_imageViewer.currentFrame);
    end

%%
%
    function checkboxPreprocessFrame_Callback(~,~)
        master.obj_imageViewer.setFrame(master.obj_imageViewer.currentFrame);
    end
end