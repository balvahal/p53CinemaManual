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
    tempMap = containers.Map({num2str(i)},{tempArray});
    obj_data.manualTrackingData = [obj_data.manualTrackingData;tempMap];
    tempMap = containers.Map({num2str(i)},{linspace(1,9,9)});
    obj_data.timepoints = [obj_data.timepoints;tempMap];
    obj_data.cellIDs{end+1} = num2str(i);
end
end