%%
%
function obj_data = p53CinemaManual_method_data_importCentroidsTracks(obj_data,centroidsTracks,selectedPosition)
firsttimepoint = centroidsTracks.singleCells(1).point;
firsttimepoint = sum(firsttimepoint,2);
number_of_cells = sum(firsttimepoint~=0);
for i = 1:number_of_cells
    tempArray = zeros(length(centroidsTracks.singleCells),2);
    for j = 1:length(centroidsTracks.singleCells)
        tempPoints = centroidsTracks.singleCells(j).point;
        tempArray(j,:) = tempPoints(i,:);
    end
    newHash = obj_data.newCellHash;
    newHash('manualTrackingData') = tempArray;
    newHash('timepoints') = linspace(1,9,9);
    newHash('stagePositionNumber') = selectedPosition;
    obj_data.cellPerspective(num2str(i)) = newHash;
end
end