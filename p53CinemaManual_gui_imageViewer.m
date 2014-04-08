%% p53CinemaManual_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_imageViewer(objImageViewer)
%%
% The width and height of the images collected.
IM_width = 1008;
IM_height = 768;
%% Create the figure
%
myunits = get(0,'units');
set(0,'units','pixels');
Pix_SS = get(0,'screensize');
set(0,'units','characters');
Char_SS = get(0,'screensize');
ppChar = Pix_SS./Char_SS;
set(0,'units',myunits);
fwidth = 1.1*IM_width/ppChar(3);
fheight = (1.1*IM_height + 100)/ppChar(4);
fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Renderer','OpenGL','Position',[fx fy fwidth fheight],...
    'DeleteFcn',{@fDeleteFcn},...
    'ButtonDownFcn',{@fButtonDownFcn},...
    'WindowButtonMotionFcn',{@fHover});
%% Create the axes that will show the image
% source image
hwidth = IM_width/ppChar(3);
hheight = IM_height/ppChar(4);
hx = (fwidth-hwidth)/2;
hy = (fheight-hheight)/2;
hSourceImage = axes('Units','characters','DrawMode','fast','Visible','off',...
    'Position',[hx hy hwidth hheight]...
    );

%% Create the axes that will show the image
% highlighted cell with hover
hHighlight = axes('Units','characters','DrawMode','fast','Visible','off',...
    'Position',[hx hy hwidth hheight]...
    );

%% Create the axes that will show the image
% selected cell with click
hSelectedCell = axes('Units','characters','DrawMode','fast','Visible','off',...
    'Position',[hx hy hwidth hheight]...
    );

%% Create the axes that will show the image
% previously annotated cells
hAnnotations = axes('Units','characters','DrawMode','fast','Visible','off',...
    'Position',[hx hy hwidth hheight]...
    );
%%
% store the uicontrol handles in the figure handles via guidata()
handles.SourceImage = hSourceImage;
handles.Highlight = hHighlight;
handles.SelectedCell = hSelectedCell;
handles.Annotations = hAnnotations;
handles.ppChar = ppChar;
guidata(f,handles);
%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
%%
%
    function fDeleteFcn(~,~)
        %do nothing. This means only the master object can close this
        %window.
        disp('deleted');
    end
%%
%
    function fButtonDownFcn(~,~)
        myCurrentPoint = objImageViewer.pixelxy;
        if ~isempty(myCurrentPoint)
            mystr = sprintf('x = %d\ny = %d',myCurrentPoint(1),myCurrentPoint(2));
            disp(mystr);
        end
    end
%%
% Translate the mouse position into the pixel location in the source image
    function fHover(~,~)
        objImageViewer.getPixelxy;
    end
end