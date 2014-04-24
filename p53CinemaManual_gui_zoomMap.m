%% p53CinemaManual_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_zoomMap(master)
%% Create the axes that will show the contrast histogram
%
if master.obj_imageViewer.image_width/master.obj_imageViewer.image_height > 1
    % then maximize the width
    hwidthaxes = 384/master.ppChar(1);
    hheightaxes = 384*master.obj_imageViewer.image_height/master.obj_imageViewer.image_width/master.ppChar(2);
else
    % then maximize the height
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
    'CloseRequestFcn',{@fCloseRequestFcn},...
    'KeyPressFcn',{@fKeyPressFcn},...
    'WindowButtonDownFcn',{@fWindowButtonDownFcn});
%% Add axes that fit the figure 1 to 1
%
hx = 0;
hy = 0;
haxesZoomMap = axes('Units','characters',...
    'Position',[hx hy hwidthaxes hheightaxes],'YDir','reverse','Visible','on',...
    'XLim',[0.5,master.obj_imageViewer.image_width+0.5],'YLim',[0.5,master.obj_imageViewer.image_height+0.5]);
%% Add the image
%
colormap(haxesZoomMap,gray(255));
sourceImage = image('Parent',haxesZoomMap,'CData',master.obj_imageViewer.currentImage);

%% Add the rectangle that will be used to control the zoom and pan
%
hzoomMapRect = patch('Parent',haxesZoomMap,...
    'Vertices',[1, 1;master.obj_imageViewer.image_width, 1;master.obj_imageViewer.image_width, master.obj_imageViewer.image_height;1, master.obj_imageViewer.image_height],...
    'Faces',[1,2,3,4],...
    'LineStyle','none','FaceColor',[255 215 0]/255,'FaceAlpha',0.2,...
    'Visible','off');
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
    function fKeyPressFcn(~,keyInfo)
        switch keyInfo.Key
            case 'equal' %or |plus|
                %%
                % Zoom in
                master.obj_imageViewer.zoomIn;
            case 'hyphen' % or |minus|
                %%
                % Zoom out
                master.obj_imageViewer.zoomOut;
            case '0'
                %%
                % Return to top level zoom
                master.obj_imageViewer.zoomTop;
        end
    end
%%
%
    function fWindowButtonDownFcn(~,~)
        if master.obj_imageViewer.zoomIndex == 1
            return
        end
        %%
        %
        set(handles.zoomMapRect,'Visible','off');
        myCurrentPoint = get(f,'CurrentPoint');
        figureSize = get(f,'Position');
        myCurrentPoint = [myCurrentPoint(1),figureSize(4)-myCurrentPoint(2)];
        myCurrentPoint(1) = myCurrentPoint(1)/figureSize(3)*master.obj_imageViewer.image_width;
        myCurrentPoint(2) = myCurrentPoint(2)/figureSize(4)*master.obj_imageViewer.image_height;
        newHalfWidth = master.obj_imageViewer.image_width*master.obj_imageViewer.zoomArray(master.obj_imageViewer.zoomIndex)/2;
        newHalfHeight = master.obj_imageViewer.image_height*master.obj_imageViewer.zoomArray(master.obj_imageViewer.zoomIndex)/2;
        %%
        % make sure the center does not move the rectangle |off screen|
        if myCurrentPoint(1) - newHalfWidth < 1
            myCurrentPoint(1) = newHalfWidth + 1;
        elseif myCurrentPoint(1) + newHalfWidth > master.obj_imageViewer.image_width
            myCurrentPoint(1) = master.obj_imageViewer.image_width - newHalfWidth;
        end
        
        if myCurrentPoint(2) - newHalfHeight < 1
            myCurrentPoint(2) = newHalfHeight + 1;
        elseif myCurrentPoint(2) + newHalfHeight > master.obj_imageViewer.image_height
            myCurrentPoint(2) = master.obj_imageViewer.image_height - newHalfHeight;
        end
        
        myVertices(1,:) = round(myCurrentPoint + [-newHalfWidth,-newHalfHeight]);
        myVertices(2,:) = round(myCurrentPoint + [newHalfWidth,-newHalfHeight]);
        myVertices(3,:) = round(myCurrentPoint + [newHalfWidth,newHalfHeight]);
        myVertices(4,:) = round(myCurrentPoint + [-newHalfWidth,newHalfHeight]);
        
        set(hzoomMapRect,'Vertices',myVertices);
        master.obj_imageViewer.zoomPan;
        set(handles.zoomMapRect,'Visible','on');
        
    end
end