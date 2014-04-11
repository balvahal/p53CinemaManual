%% p53CinemaManual_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_imageViewer(master)
%% Create the figure
%
fwidth = 1.1*master.obj_imageViewer.image_width/master.ppChar(1);
fheight = (1.1*master.obj_imageViewer.image_height + 100)/master.ppChar(2);
fx = 10;
fy = 10;
f = figure('Visible','off','Units','characters','MenuBar','none',...
'Resize','off',...
'Renderer','OpenGL','Position',[fx fy fwidth fheight],...
'CloseRequestFcn',{@fCloseRequestFcn},...
'KeyPressFcn',{@fKeyPressFcn},...
'WindowButtonDownFcn',{@fWindowButtonDownFcn},...
'WindowButtonMotionFcn',{@fHover});
%% Create the axes that will show the image
% source image
hwidth = master.obj_imageViewer.image_width/master.ppChar(1);
hheight = master.obj_imageViewer.image_height/master.ppChar(2);
hx = (fwidth-hwidth)/2;
hy = (fheight-hheight-100/master.ppChar(2))/2+100/master.ppChar(2);
haxesImageViewer = axes('Units','characters','DrawMode','fast',...
'Position',[hx hy hwidth hheight],'YDir','reverse',...
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
scatterPatch = patch('XData',rand(1,16)*master.obj_imageViewer.image_width,'YData',rand(1,16)*master.obj_imageViewer.image_height,...
'EdgeColor','none','FaceColor','none','MarkerSize',15,...
'Marker','o','MarkerEdgeColor','none','MarkerFaceColor','flat',...
'FaceVertexCData',cmapHighlight,'Parent',haxesImageViewer);
highlightPatch = patch('XData',ones(1,16),'YData',ones(1,16),...
'LineWidth',4,'EdgeColor','flat','FaceColor','none',...
'FaceVertexCData',cmapHighlight,'Parent',haxesImageViewer);



%% Create an axes
% selected cell with click haxesSelectedCell =
% axes('Units','characters','DrawMode','fast','color','none',...
%     'Position',[hx hy hwidth hheight],...
%     'XLim',[1,master.image_width],'YLim',[1,master.image_height]);

%% Create an axes
% previously annotated cells haxesAnnotations =
% axes('Units','characters','DrawMode','fast','color','none',...
%     'Position',[hx hy hwidth hheight],...
%     'XLim',[1,master.image_width],'YLim',[1,master.image_height]);
%% Create controls
% Slider bar and two buttons
hwidth = master.obj_imageViewer.image_width/master.ppChar(1);
hheight = 20/master.ppChar(2);
hx = (fwidth-hwidth)/2;
hy = 70/master.ppChar(2);

sliderStep = 1/(master.obj_fileManager.numImages - 1);
hsliderExploreStack = uicontrol('Style','slider','Units','characters',...
'Min',0,'Max',1,'BackgroundColor',[255 215 0]/255,...
'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
'Callback',{@sliderExploreStack_Callback});


hwidth = 100/master.ppChar(1);
hheight = 30/master.ppChar(2);
hx = 20/master.ppChar(1);
hy = 20/master.ppChar(2);
hpushbuttonFirstImage = uicontrol('Style','pushbutton','Units','characters',...
'FontSize',14,'FontName','Verdana','BackgroundColor',[255 215 0]/255,...
'String','First Image','Position',[hx hy hwidth hheight],...
'Callback',{@pushbuttonFirstImage_Callback});

hx = fwidth - hwidth - 20/master.ppChar(1);
hpushbuttonLastImage = uicontrol('Style','pushbutton','Units','characters',...
'FontSize',14,'FontName','Verdana','BackgroundColor',[60 179 113]/255,...
'String','Last Image','Position',[hx hy hwidth hheight],...
'Callback',{@pushbuttonLastImage_Callback});
%%
% store the uicontrol handles in the figure handles via guidata()
handles.axesSourceImage = haxesImageViewer;
% handles.axesHighlight = haxesHighlight; handles.axesSelectedCell =
% haxesSelectedCell; handles.axesAnnotations = haxesAnnotations;
handles.sliderExploreStack = hsliderExploreStack;
handles.cmapHighlight = cmapHighlight;
handles.patch = highlightPatch;
handles.scatterPatch = scatterPatch;
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
            %colormap(haxesImageViewer,gray(255));
            set(sourceImage,'CData',master.obj_imageViewer.currentImage);
            disp('next image')
        case 'comma'
            master.obj_imageViewer.previousFrame;
            %colormap(haxesImageViewer,gray(255));
            set(sourceImage,'CData',master.obj_imageViewer.currentImage);
            disp('previous image')
    end
end
%%
%
function fWindowButtonDownFcn(~,~)
    %%
    % This if statement prevents multiple button firings from a single
    % click event
    if master.obj_imageViewer.isMyButtonDown
        return
    end
    %%
    %
    master.obj_imageViewer.isMyButtonDown = true;
    p53CinemaManual_function_imageViewer_updateSelectedCell(master);
    p53CinemaManual_function_imageViewer_updateAnnotations(master);
    master.obj_imageViewer.isMyButtonDown = false;
end
%%
% Translate the mouse position into the pixel location in the source image
function fHover(~,~)
    master.obj_imageViewer.getPixelxy;
    p53CinemaManual_function_imageViewer_updateHighlight(master);
end
%%
%
function sliderExploreStack_Callback(~,~)
    p53CinemaManual_function_imageViewer_updateSourceAxes(master);
end
%%
%
function pushbuttonFirstImage_Callback(~,~)
    p53CinemaManual_function_imageViewer_updateSourceAxes(master);
end
%%
%
function pushbuttonLastImage_Callback(~,~)
    p53CinemaManual_function_imageViewer_updateSourceAxes(master);
end
end