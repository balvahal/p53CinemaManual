%% p53CinemaManual_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_contrast(master)
%% Create the figure
%
fwidth = 1.1*256/master.ppChar(1);
fheight = 1.1*384/master.ppChar(2);
fx = 10;
fy = 10;
f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Resize','off',...
    'Renderer','OpenGL','Position',[fx fy fwidth fheight],...
    'CloseRequestFcn',{@fCloseRequestFcn});
%% Create the axes that will show the contrast histogram
% 
hwidth = 256/master.ppChar(1);
hheight = 256/master.ppChar(2);
hx = (fwidth-hwidth)/2;
hy = (fheight-hheight-128/master.ppChar(2))/2+128/master.ppChar(2);
haxesContrast = axes('Units','characters','DrawMode','fast',...
    'Position',[hx hy hwidth hheight]);

master.obj_imageViewer.findImageHistogram;
plot(haxesContrast,master.obj_imageViewer.constrastHistogram);
%% Create controls
%  two slider bars
hwidth = 256/master.ppChar(1);
hheight = 20/master.ppChar(2);
hx = (fwidth-hwidth)/2;
hy = 70/master.ppChar(2);

sliderStep = 1/(256 - 1);
hsliderMax = uicontrol('Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[255 215 0]/255,...
    'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderMax_Callback});

hx = (fwidth-hwidth)/2;
hy = 30/master.ppChar(2);

sliderStep = 1/(256 - 1);
hsliderMin= uicontrol('Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[40 215 100]/255,...
    'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderMin_Callback});

%%
% store the uicontrol handles in the figure handles via guidata()
handles.axesContrast = haxesContrast;
handles.sliderMax = hsliderMax;
handles.sliderMin = hsliderMin;
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
    function sliderMax_Callback(~,~)
        p53CinemaManual_function_imageViewer_updateSourceAxes(master);
    end
%%
%
    function sliderMin_Callback(~,~)
        p53CinemaManual_function_imageViewer_updateSourceAxes(master);
    end
end