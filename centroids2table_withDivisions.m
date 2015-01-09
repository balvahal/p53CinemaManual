function centroids = centroids2table(annotation, divisions)
trackedCellIds = annotation.getTrackedCellIds;
centroids = zeros(length(annotation) * length(annotation), 5);
counter = 1;
for i= 1:length(annotation.singleCells)
    %         extractedData = annotation.singleCells(i).point(trackedCellIds,:);
    %         subsetting = counter:(counter + size(extractedData,1) - 1);
    %         centroids(subsetting,3:4) = extractedData;
    %         centroids(subsetting,5) = annotation.singleCells(i).value(trackedCellIds,:);
    %         centroids(subsetting,1) = trackedCellIds;
    %         centroids(subsetting,2) = repmat(i, size(extractedData,1), 1);
    %         counter = counter + size(extractedData,1);
    [CentroidsTemp, cell_ids] = annotation.getCentroids(i);
    divisionStatus = zeros(length(cell_ids),1);
    for j=1:length(cell_ids)
        divisionEvent = divisions.getCentroid(i,cell_ids(j));
        divisionStatus(j) = divisionEvent(1) > 0;
    end
    values = annotation.getValues(i);
    subsetIndex = counter:counter + length(values) - 1;
    centroids(subsetIndex,1) = cell_ids;
    centroids(subsetIndex,2:3) = CentroidsTemp;
    centroids(subsetIndex,4) = repmat(i,length(subsetIndex),1);
    centroids(subsetIndex,5) = divisionStatus;
    counter = max(subsetIndex) + 1;
end
centroids = array2table(centroids, 'VariableNames', {'cell_id', 'timepoint', 'centroid_col', 'centroid_row', 'division'});
end