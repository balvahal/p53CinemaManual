%% p53CinemaManual_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_zoomMap(master)
%% Create the axes that will show the contrast histogram
% 
if master.obj_imageViewer.image_width/master.obj_imageViewer.image_height > 1
    % then maximize the width
    hwidthaxespixels = 384;
    hheightaxespixels = round(384*master.obj_imageViewer.image_height/master.obj_imageViewer.image_width);
    hwidthaxes = 384/master.ppChar(1);
    hheightaxes = 384*master.obj_imageViewer.image_height/master.obj_imageViewer.image_width/master.ppChar(2);
else
    % then maximize the height
    hheightaxespixels = 384;
    hheightaxespixels = round(384*master.obj_imageViewer.image_width/master.obj_imageViewer.image_height);
    hheightaxes  = 384/master.ppChar(2);
    hwidthaxes  = 384*master.obj_imageViewer.image_width/master.obj_imageViewer.image_height/master.ppChar(1);
end
%% Create the figure
%
fx = 10;
fy = 10;
f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Resize','off','Name','Zoom Map',...
    'Renderer','OpenGL','Position',[fx fy hwidthaxes hheightaxes],...
    'CloseRequestFcn',{@fCloseRequestFcn});
%% Add axes that fit the figure 1 to 1
%
hx = 0;
hy = 0;
haxesZoomMap = axes('Units','characters',...
    'Position',[hx hy hwidthaxes hheightaxes],'YDir','reverse','Visible','on',...
    'XLim',[0,hwidthaxespixels],'YLim',[0,hheightaxespixels]);
%% Add the image
%
colormap(haxesZoomMap,gray(255));
    lowResImage = imresize(master.obj_imageViewer.currentImage,[hheightaxespixels,hwidthaxespixels]); %otherwise the imrect drag doesn't work
sourceImage = image('Parent',haxesZoomMap,'CData',lowResImage);

%% Add the rectangle that will be used to control the zoom and pan
%
hzoomMapRect = imrect(haxesZoomMap,[0 0 hwidthaxespixels hheightaxespixels]);
%hzoomMapRect.addNewPositionCallback(hzoomMapRect,@zoomMapRect_PositionConstraintFcn);
setFixedAspectRatioMode(hzoomMapRect,true);
%%
% store the uicontrol handles in the figure handles via guidata()
handles.axesZoomMap = haxesZoomMap;
handles.sourceImage = sourceImage;
handles.zoomMapRect = hzoomMapRect;
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
    function zoomMapRect_PositionConstraintFcn()
    disp('hello');
    end
end