function lineageTree = generateLineageTree(centroidsTracks, centroidsDivisions)
trackedCells = centroidsTracks.getTrackedCellIds;
lineageTree = zeros(length(trackedCells), length(centroidsTracks.singleCells));
for i=1:length(trackedCells)
    currentTrack = centroidsTracks.getCellTrack(trackedCells(i));
    trackedPositions = find(currentTrack(:,1) > 0);
    lineageTree(i, min(trackedPositions):max(trackedPositions)) = trackedCells(i);
end
for t=1:length(centroidsDivisions.singleCells)
    [~, dividing_cells] = centroidsDivisions.getCentroids(t);
    [divisions, currentCellId] = centroidsTracks.getCentroids(t);
    divisions = round(divisions(ismember(currentCellId,dividing_cells),:));
    [~, dividing_cells] = ismember(dividing_cells,trackedCells);
    if(~isempty(dividing_cells))
        [~, uniqueRowId] = unique(divisions, 'rows');
        for i=1:length(uniqueRowId)
            involvedCells = find(divisions(:,1) == divisions(uniqueRowId(i),1) & divisions(:,2) == divisions(uniqueRowId(i),2));
            if(length(involvedCells) == 2)
                traceInformation = lineageTree(dividing_cells(involvedCells),1:t);
                [~, maxIndex] = max(sum(traceInformation > 0,2));
                maxIndex = maxIndex(1);
                cellOptions = 1:2;
                receiverCell = cellOptions(cellOptions ~= maxIndex);
                lineageTree(dividing_cells(involvedCells(receiverCell)),1:t) = lineageTree(dividing_cells(involvedCells(maxIndex)),1:t);
            end
        end
    end
end
end