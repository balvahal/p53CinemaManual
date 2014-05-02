%%
%
function obj_data = p53CinemaManual_method_data_importCentroidsTracks(obj_data,centroidsTracks)
firsttimepoint = centroidsTracks.singleCells(1).point;
firsttimepoint = sum(firsttimepoint,2);
number_of_cells = sum(firsttimepoint~=0);
for i = 1:number_of_cells
    tempArray = zeros(length(centroidsTracks.singleCells),2);
    for j = 1:length(centroidsTracks.singleCells)
        tempPoints = centroidsTracks.singleCells(j).point;
        tempArray(j,:) = tempPoints(i,:);
    end
    obj_data.cellPerspectivePrototype('manualTrackingData') = tempArray;
    obj_data.cellPerspectivePrototype('timepoints') = linspace(1,9,9);
    obj_data.cellPerspective(num2str(i)) = obj_data.cellPerspectivePrototype;
end
end