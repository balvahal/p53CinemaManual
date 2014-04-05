%% p53CinemaManual_gui_imageViewer
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_imageViewer(obj)
%%
% The width and height of the images collected.
IM_width = 1344;
IM_height = 1024;
%% Create the figure
%
myunits = get(0,'units');
set(0,'units','pixels');
Pix_SS = get(0,'screensize');
set(0,'units','characters');
Char_SS = get(0,'screensize');
ppChar = Pix_SS./Char_SS;
set(0,'units',myunits);
fwidth = 450/ppChar(3);
fheight = 300/ppChar(4);
fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Renderer','OpenGL','Position',[fx fy fwidth fheight]);
%% Create the axes that will show the image
%
hwidth = 100/ppChar(3);
hheight = 70/ppChar(4);
hx = 20/ppChar(3);
hygap = (fheight - 3*hheight)/4;
hy = fheight - (hygap + hheight);
ha = axes('Units','characters','DrawMode','fast','Visible','off',...
    ''
    'Position',[hx hy hwidth hheight]);
%% Construct the components
% The pause, stop, and resume buttons
hwidth = 100/ppChar(3);
hheight = 70/ppChar(4);
hx = 20/ppChar(3);
hygap = (fheight - 3*hheight)/4;
hy = fheight - (hygap + hheight);
hpushbuttonPause = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',[255 215 0]/255,...
    'String','Pause','Position',[hx hy hwidth hheight],...
    'Callback',{@pushbuttonPause_Callback});

hy = hy - (hygap + hheight);
hpushbuttonResume = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',[60 179 113]/255,...
    'String','Resume','Position',[hx hy hwidth hheight],...
    'Callback',{@pushbuttonResume_Callback});

hy = hy - (hygap + hheight);
hpushbuttonStop = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',14,'FontName','Verdana','BackgroundColor',[205 92 92]/255,...
    'String','Stop','Position',[hx hy hwidth hheight],...
    'Callback',{@pushbuttonStop_Callback});

align([hpushbuttonPause,hpushbuttonResume,hpushbuttonStop],'Center','None');
%%
% A text box showing the time until the next acquisition
hwidth = 250/ppChar(3);
hheight = 50/ppChar(4);
hx = (fwidth - (20/ppChar(3) + 100/ppChar(3) + hwidth))/2 + 20/ppChar(3) + 100/ppChar(3);
hygap = (fheight - hheight)/2;
hy = fheight - (hygap + hheight);
htextTime = uicontrol('Style','text','String','No Acquisition',...
    'Units','characters','FontSize',20,'FontWeight','bold',...
    'FontName','Verdana',...
    'Position',[hx hy hwidth hheight]);
%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
%%
%
    function pushbuttonPause_Callback(source,eventdata)
        disp('pause');
    end
%%
%
    function pushbuttonResume_Callback(source,eventdata)
        disp('resume');
    end
%%
%
    function pushbuttonStop_Callback(source,eventdata)
        disp('stop');
    end
end