%%
%
function [] = p53CinemaManual_function_imageViewer_updateAnnotations(master)
%% Organize the relevant variables
%

if isempty(master.obj_imageViewer.pixelxy)
    return
end
%% Organize the relevant variables
%
handles = guidata(master.obj_imageViewer.gui_imageViewer);
%%
%

set(handles.scatterPatch,'XData',rand(1,16)*master.image_width,'YData',rand(1,16)*master.image_height);