%%
%
function [] = p53CinemaManual_function_imageViewer_updateSourceAxes(master)
%% Organize the relevant variables
%

%%
%
myCurrentPoint = master.obj_imageViewer.pixelxy;
if ~isempty(myCurrentPoint)
    %% add to data set
    mystr = sprintf('x = %d\ny = %d',myCurrentPoint(1),myCurrentPoint(2));
    disp(mystr);
    drawnow;
end