function centroids = centroids2table(annotation)
    trackedCellIds = annotation.getTrackedCellIds;
    centroids = zeros(length(annotation) * length(annotation), 5);
    counter = 1;
    for i= 1:length(annotation.singleCells)
        extractedData = annotation.singleCells(i).point(trackedCellIds,:);
        subsetting = counter:(counter + size(extractedData,1) - 1);
        centroids(subsetting,3:4) = extractedData;
        centroids(subsetting,5) = annotation.singleCells(i).value(trackedCellIds,:);
        centroids(subsetting,1) = trackedCellIds;
        centroids(subsetting,2) = repmat(i, size(extractedData,1), 1);
        counter = counter + size(extractedData,1);
    end
    centroids = array2table(centroids, 'VariableNames', {'cell_id', 'timepoint', 'x', 'y', 'value'});
end