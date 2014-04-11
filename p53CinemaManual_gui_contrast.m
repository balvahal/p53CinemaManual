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
plot(haxesContrast,master.obj_imageViewer.contrastHistogram);
%% Create controls
%  two slider bars
hwidth = 256/master.ppChar(1);
hheight = 20/master.ppChar(2);
hx = (fwidth-hwidth)/2;
hy = 70/master.ppChar(2);

sliderStep = 1/(256 - 1);
hsliderMax = uicontrol('Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[255 215 0]/255,...
    'Value',1,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderMax_Callback});
hListener = handle.listener(hsliderMax,'ActionEvent',@sliderMax_Callback);
setappdata(hsliderMax,'sliderListener',hListener);

hx = (fwidth-hwidth)/2;
hy = 30/master.ppChar(2);

sliderStep = 1/(256 - 1);
hsliderMin= uicontrol('Style','slider','Units','characters',...
    'Min',0,'Max',1,'BackgroundColor',[40 215 100]/255,...
    'Value',0,'SliderStep',[sliderStep sliderStep],'Position',[hx hy hwidth hheight],...
    'Callback',{@sliderMin_Callback});
hListener = handle.listener(hsliderMin,'ActionEvent',@sliderMin_Callback);
setappdata(hsliderMin,'sliderListener',hListener);

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
        sstep = get(hsliderMax,'SliderStep');
        mymax = get(hsliderMax,'Value');
        mymin = get(hsliderMin,'Value');
        if mymax == 0
            set(hsliderMax,'Value',sstep(1));
            set(hsliderMin,'Value',0);
        elseif mymax <= mymin
            set(hsliderMin,'Value',mymax-sstep(1));
        end 
        master.obj_imageViewer.newColormapFromContrastHistogram;
    end
%%
%
    function sliderMin_Callback(~,~)
        sstep = get(hsliderMax,'SliderStep');
        mymax = get(hsliderMax,'Value');
        mymin = get(hsliderMin,'Value');
        if mymin == 1
            set(hsliderMax,'Value',1);
            set(hsliderMin,'Value',1-sstep(1));
        elseif mymin >= mymax
            set(hsliderMax,'Value',mymin+sstep(1));
        end 
        master.obj_imageViewer.newColormapFromContrastHistogram;
    end
end