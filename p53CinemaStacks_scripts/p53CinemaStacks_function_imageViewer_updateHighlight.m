%%
%
function [] = p53CinemaManual_function_imageViewer_updateHighlight(master)
if isempty(master.obj_imageViewer.pixelxy)
    return
end
%% Organize the relevant variables
%
handles = guidata(master.obj_imageViewer.gui_imageViewer);
ang = 0:.4:2*pi;
w = 50;
h = 50;
%%
%
myXY = master.obj_imageViewer.pixelxy;

    %% draw a circle
    %
    set(handles.patch,'XData',myXY(1)+w*cos(ang)/2,'YData',myXY(2)+h*sin(ang)/2);
