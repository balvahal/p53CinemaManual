function centroids = centroids2table_withCellFates(annotation, divisions, death)
% This function transforms centroids objects to a table format, useful as a
% backup or for interfacing with other tracking and measurements scripts.
% It receives as input three CentroidTimeseries objects, corresponding to
% centroidsTracks (annotation), centroidsDivisions (divisions) and
% centroidsDeath (death). These objects are generated by the
% p53CinemaManual tracking GUI.

trackedCellIds = annotation.getTrackedCellIds;
centroids = zeros(length(trackedCellIds) * length(annotation.singleCells), 7);
counter = 1;
for i= 1:length(annotation.singleCells)
    [CentroidsTemp, cell_ids] = annotation.getCentroids(i);
    divisionStatus = zeros(length(cell_ids),1);
    for j=1:length(cell_ids)
        divisionEvent = divisions.getCentroid(i,cell_ids(j));
        divisionStatus(j) = divisionEvent(1) > 0;
    end
    deathStatus = zeros(length(cell_ids),1);
    for j=1:length(cell_ids)
        deathEvent = death.getCentroid(i,cell_ids(j));
        deathStatus(j) = deathEvent(1) > 0;
    end
    if(~isempty(CentroidsTemp))
        values = annotation.getValues(i);
        subsetIndex = counter:(counter + length(values)) - 1;
        centroids(subsetIndex,1) = cell_ids;
        centroids(subsetIndex,2:3) = CentroidsTemp;
        centroids(subsetIndex,4) = repmat(i,length(subsetIndex),1);
        centroids(subsetIndex,5) = divisionStatus;
        centroids(subsetIndex,6) = deathStatus;
        centroids(subsetIndex,7) = values;
        counter = max(subsetIndex) + 1;
    end
end
centroids = centroids(1:(counter - 1),:);
centroids = array2table(centroids, 'VariableNames', {'cell_id', 'centroid_col', 'centroid_row', 'timepoint', 'division', 'death', 'value'});
end