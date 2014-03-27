function centroids = centroids2table(annotation)
    minCellId = length(annotation);
    maxCellId = 1;
    for i=1:length(annotation)
        if(sum(annotation(i).point(:,1) > 0) > 0)
            firstCell = find(annotation(i).point(:,1) > 0, 1, 'first');
            lastCell = find(annotation(i).point(:,1) > 0, 1, 'last');
            minCellId = min(minCellId, firstCell);
            maxCellId = max(maxCellId, lastCell);
        end
    end
    centroids = zeros((maxCellId - minCellId + 1) * length(annotation), 4);
    counter = 1;
    for i= 1:length(annotation)
        extractedData = annotation(i).point(minCellId:maxCellId,:);
        centroids(counter:(counter + size(extractedData,1) - 1),3:4) = extractedData;
        centroids(counter:(counter + size(extractedData,1) - 1),1) = minCellId:maxCellId;
        centroids(counter:(counter + size(extractedData,1) - 1),2) = repmat(i, size(extractedData,1), 1);
        counter = counter + size(extractedData,1);
    end
end