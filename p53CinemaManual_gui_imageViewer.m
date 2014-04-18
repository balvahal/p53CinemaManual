%% p53CinemaManual_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_imageViewer(master)
%% Create the figure
%
fwidth = (1.1*1344+200)/master.ppChar(1);
fheight = (1.1*1024)/master.ppChar(2);
%fwidth = 1.1*master.obj_imageViewer.image_width/master.ppChar(1);
%fheight = (1.1*master.obj_imageViewer.image_height + 100)/master.ppChar(2);
fx = 10/master.ppChar(1);
fy = 10/master.ppChar(2);
f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Resize','off',...
    'Renderer','OpenGL','Position',[fx fy fwidth fheight],...
    'CloseRequestFcn',{@fCloseRequestFcn},...
    'KeyPressFcn',{@fKeyPressFcn},...
    'WindowButtonDownFcn',{@fWindowButtonDownFcn},...
    'WindowButtonMotionFcn',{@fHover},...
    'WindowScrollWheelFcn',{@fWindowScrollWheelFcn});
%% Create the axes that will show the image
% source image
hwidth = 1344/master.ppChar(1);
hheight = 1024/master.ppChar(2);
hx = (fwidth-hwidth-200/master.ppChar(1))/2;
hy = (fheight-hheight)/2;
%hwidth = master.obj_imageViewer.image_width/master.ppChar(1);
%hheight = master.obj_imageViewer.image_height/master.ppChar(2);
%hx = (fwidth-hwidth)/2;
%hy = (fheight-hheight-100/master.ppChar(2))/2+100/master.ppChar(2);
haxesImageViewer = axes('Units','characters','DrawMode','fast',...
    'Position',[hx hy hwidth hheight],'YDir','reverse','Visible','off',...
    'XLim',[1,master.obj_imageViewer.image_width],'YLim',[1,master.obj_imageViewer.image_height]);
%plot(haxesImageViewer,rand(1,10));
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

%% Create controls
% Slider bar and two buttons
hwidth = 20/master.ppChar(1);
hheight = 1024/master.ppChar(2);
hx = fwidth-180/master.ppChar(1);
hy = (fheight-hheight)/2;

% hwidth = master.obj_imageViewer.image_width/master.ppChar(1);
% hheight = 20/master.ppChar(2);
% hx = (fwidth-hwidth)/2;
% hy = 70/master.ppChar(2);

sliderStep = 1/(master.obj_fileManager.numImages - 1);
hsliderExploreStack = uicontrol('Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[255 215 0]/255,...
    'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderExploreStack_Callback});
hListener = handle.listener(hsliderExploreStack,'ActionEvent',@sliderExploreStack_Callback);
setappdata(hsliderExploreStack,'sliderListener',hListener);

hwidth = 100/master.ppChar(1);
hheight = 30/master.ppChar(2);
hx = 20/master.ppChar(1);
hy = 20/master.ppChar(2);
hpushbuttonFirstImage = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','BackgroundColor',[255 215 0]/255,...
    'String','First Image','Position',[hx hy hwidth hheight],...
    'Callback',{@pushbuttonFirstImage_Callback});

hx = fwidth - hwidth - 20/master.ppChar(1);
hpushbuttonLastImage = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','BackgroundColor',[60 179 113]/255,...
    'String','Last Image','Position',[hx hy hwidth hheight],...
    'Callback',{@pushbuttonLastImage_Callback});
%%
% store the uicontrol handles in the figure handles via guidata()
handles.axesImageViewer = haxesImageViewer;
handles.pushbuttonFirstImage = hpushbuttonFirstImage;
handles.pushbuttonLastImage = hpushbuttonLastImage;
handles.sliderExploreStack = hsliderExploreStack;
handles.cmapHighlight = cmapHighlight;
handles.trackedCellsPatch = trackedCellsPatch;
handles.trackedCellsPatch = selectedCellPatch;
handles.cellsInRangePatch = cellsInRangePatch;
handles.closestCellPatch = closestCellPatch;
handles.sourceImage = sourceImage;
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
            case 'backspace'
                master.obj_imageViewer.obj_cellTracker.centroidsTracks.deleteTrack(master.obj_imageViewer.selectedCell);
                master.obj_imageViewer.setImage;
        end
    end

% A function used multiple times to modify the values of image and slider
% once these have been set in the imageViewer object through functions such
% as nextFrame, previousFrame and setFrame;
    function setImage
        set(sourceImage,'CData',master.obj_imageViewer.currentImage);
        sliderStep = get(hsliderExploreStack,'SliderStep');
        set(hsliderExploreStack,'Value',sliderStep(1)*(master.obj_imageViewer.currentFrame-1));
        
        trackedCentroids = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getCentroids(master.obj_imageViewer.currentTimepoint);
        set(trackedCellsPatch, 'XData', trackedCentroids(:,2), 'YData', trackedCentroids(:,1));
        
        if(master.obj_imageViewer.selectedCell)
            selectedCentroid = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell);
            set(selectedCellPatch, 'XData', selectedCentroid(:,2), 'YData', selectedCentroid(:,1));
        else
            set(selectedCellPatch, 'XData', [], 'YData', []);
        end
        
        if(~master.obj_fileManager.preprocessMode)
            return;
        end
        
        lookupRadius = master.obj_imageViewer.obj_cellTracker.getDistanceRadius;
        currentPoint = master.obj_imageViewer.pixelxy;
        if(~isempty(currentPoint))
            highlightedCentroids = master.obj_imageViewer.obj_cellTracker.centroidsLocalMaxima.getCentroidsInRange(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
            set(cellsInRangePatch, 'XData', highlightedCentroids(:,2), 'YData', highlightedCentroids(:,1));
            
            closestCentroid = master.obj_imageViewer.obj_cellTracker.centroidsLocalMaxima.getClosestCentroid(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
            set(closestCellPatch, 'XData', closestCentroid(:,2), 'YData', closestCentroid(:,1));
        end
    end
%%
%
    function fWindowButtonDownFcn(~,~)
        %%
        % This if statement prevents multiple button firings from a single
        % click event
        %         if master.obj_imageViewer.isMyButtonDown
        %             return
        %         end
        if master.debugmode
            currentPoint = master.obj_imageViewer.getPixelxy;
            if ~isempty(currentPoint)
                mystr = sprintf('x = %d\ty = %d',currentPoint(1),currentPoint(2));
                disp(mystr);
            else
                mystr = sprintf('OUTSIDE AXES!!!');
                disp(mystr);
            end
        end
        currentPoint = master.obj_imageViewer.getPixelxy;
        if(~master.obj_imageViewer.obj_cellTracker.isTracking)
            return;
        end
        
        %         master.obj_imageViewer.isMyButtonDown = true;
        
        currentPoint = master.obj_imageViewer.getPixelxy;
        if(isempty(currentPoint))
            return;
        end
        % If the dataset has been preprocessed, perform tracking under
        % "magnet mode"
        if(master.obj_fileManager.preprocessMode)
            lookupRadius = master.obj_imageViewer.obj_cellTracker.getDistanceRadius;
            queryCentroid = master.obj_imageViewer.obj_cellTracker.centroidsLocalMaxima.getClosestCentroid(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
        else
            queryCentroid = fliplr(currentPoint);
        end
        % If this is the first time the user clicks after starting a new
        % track, define the selected cell
        if(master.obj_imageViewer.obj_cellTracker.firstClick)
            lookupRadius = master.obj_imageViewer.obj_cellTracker.getDistanceRadius / 6;
            [cellCentroid1, cell_id1] = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getClosestCentroid(master.obj_imageViewer.currentTimepoint, queryCentroid, lookupRadius);
            [cellCentroid2, cell_id2] = master.obj_imageViewer.obj_cellTracker.centroidsTracks.getClosestCentroid(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
            if(~isempty(cell_id2))
                master.obj_imageViewer.setSelectedCell(cell_id2);
                queryCentroid = cellCentroid2;
            elseif(~isempty(cell_id1))
                master.obj_imageViewer.setSelectedCell(cell_id1);
                queryCentroid = cellCentroid1;
            else
                master.obj_imageViewer.setSelectedCell(master.obj_imageViewer.obj_cellTracker.centroidsTracks.getAvailableCellId);
            end
            master.obj_imageViewer.obj_cellTracker.firstClick = 0;
        end
        
        master.obj_imageViewer.obj_cellTracker.centroidsTracks.setCentroid(master.obj_imageViewer.currentTimepoint, master.obj_imageViewer.selectedCell, queryCentroid, 1);
        master.obj_imageViewer.obj_cellTracker.setAvailableCells;
        
        master.obj_imageViewer.setImage;
        drawnow;
        frameSkip = master.obj_imageViewer.obj_cellTracker.getFrameSkip;
        master.obj_imageViewer.nextFrame;
              
        %         master.obj_imageViewer.isMyButtonDown = false;
    end

    function fWindowScrollWheelFcn(~,event)
        newFrame = master.obj_imageViewer.currentFrame - event.VerticalScrollCount;
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
        
        if(~master.obj_fileManager.preprocessMode)
            return;
        end
        
        lookupRadius = master.obj_imageViewer.obj_cellTracker.getDistanceRadius;
        highlightedCentroids = master.obj_imageViewer.obj_cellTracker.centroidsLocalMaxima.getCentroidsInRange(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
        set(cellsInRangePatch, 'XData', highlightedCentroids(:,2), 'YData', highlightedCentroids(:,1));
        closestCentroid = master.obj_imageViewer.obj_cellTracker.centroidsLocalMaxima.getClosestCentroid(master.obj_imageViewer.currentTimepoint, fliplr(currentPoint), lookupRadius);
        set(closestCellPatch, 'XData', closestCentroid(:,2), 'YData', closestCentroid(:,1));
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
end