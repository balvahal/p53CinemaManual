%% p53CinemaManual_gui_fileManager
% a simple gui to pause, stop, and resume a running MDA
function [f] = p53CinemaManual_gui_fileManager(master)
%% Create the figure
%
set(0,'units','characters');
Char_SS = get(0,'screensize');
fwidth = 450/master.ppChar(1);
fheight = 300/master.ppChar(2);
fx = Char_SS(3) - (Char_SS(3)*.1 + fwidth);
fy = Char_SS(4) - (Char_SS(4)*.1 + fheight);
f = figure('Visible','off','Units','characters','MenuBar','none',...
    'Renderer','OpenGL','Position',[fx fy fwidth fheight]);
%% Construct the components
% The pause, stop, and resume buttons
hwidth = 120/master.ppChar(1);
hheight = 20/master.ppChar(2);
hmargin = 25/master.ppChar(2);
hmargin_short = 7/master.ppChar(2);
hx = 20/ppChar(3);
hygap = (fheight - 3*hheight)/4;
hy = fheight - (hmargin + hheight);

%% Layout: file path information
htextDatabasePath = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Database file','Position',[hx, hy, hwidth, hheight],...
    'Enable', 'inactive','parent',f);
heditDatabasePath = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Database file','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'parent',f);
hbuttonDatabasePath = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Browse','Position',[hx + 2*hmargin + 2.5*hwidth, hy, hwidth * 0.75, hheight],...
    'Callback',{@pushbuttonDatabasePath_Callback},'parent',f);

hy = hy - hheight - hmargin_short;
htextRawDataPath = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Raw data path','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditRawDataPath = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Database file','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Enable', 'off', 'parent',f);

hy = hy - hheight - hmargin_short;
htextSegmentDataPath = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Segment data path','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditSegmentDataPath = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Database file','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Enable', 'off', 'parent',f);

%% Layout: image sequence information (group, position and channel)
hy = hy - hheight - hmargin;
htextGroupLabel = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Group label','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hpopupGroupLabel = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Database file','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Enable', 'off', 'parent',f);

hy = hy - hheight - hmargin_short;
htextStagePosition = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Stage position','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hpopupStagePosition = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Database file','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Enable', 'off', 'parent',f);

hy = hy - hheight - hmargin_short;
htextPimaryChannel = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Primary channel','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
hpopupPimaryChannel = uicontrol('Style','popupmenu','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Database file','Position',[hx + hmargin + hwidth, hy, hwidth * 1.5, hheight],...
    'Enable', 'off', 'parent',f);

%% Layout: Data loading options
hy = hy - hheight - hmargin;
htextImageResize = uicontrol('Style','text','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Resize factor','Position',[hx, hy, hwidth, hheight],...
    'parent',f);
heditImageResize = uicontrol('Style','edit','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','1.0','Position',[hx + hmargin + hwidth, hy, hwidth * 0.5, hheight],...
    'parent',f);
hcheckboxPreprocess = uicontrol('Style','checkbox','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Preprocess','Position',[hx + hmargin + 1.75*hwidth, hy, hwidth * 0.75, hheight],...
    'parent',f);

%% Layout: Load button
hy = hy - hheight - hmargin;
heditImageResize = uicontrol('Style','pushbutton','Units','characters',...
    'FontSize',10,'FontName','Arial','HorizontalAlignment','right',...
    'String','Load','Position',[hx + hmargin + hwidth, hy, hwidth * 0.75, hheight],...
    'parent',f);

%%
% make the gui visible
set(f,'Visible','on');

%% Callbacks
%
%%
%
    function pushbuttonDatabasePath_Callback(source,eventdata)
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