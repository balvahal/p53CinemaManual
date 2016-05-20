function filledTraces = fillLineageInformation(traces, centroidsTracks, centroidsDivisions)
    trackedCells = centroidsTracks.getTrackedCellIds;
    for t=1:length(centroidsDivisions.singleCells)
        [~, dividing_cells] = centroidsDivisions.getCentroids(t);
        [divisions, currentCellId] = centroidsTracks.getCentroids(t);
        divisions = round(divisions(ismember(currentCellId,dividing_cells),:));
        [~, dividing_cells] = ismember(dividing_cells,trackedCells);
        
        if(~isempty(divisions))
            [~, uniqueRowId] = unique(divisions, 'rows');
            for i=1:length(uniqueRowId)
                involvedCells = find(divisions(:,1) == divisions(uniqueRowId(i),1) & divisions(:,2) == divisions(uniqueRowId(i),2));
                if(length(involvedCells) == 2)
                    traceInformation = traces(dividing_cells(involvedCells),1:t);
                    [~, maxIndex] = max(sum(traceInformation,2));
                    maxIndex = maxIndex(1);
                    cellOptions = 1:2;
                    receiverCell = cellOptions(cellOptions ~= maxIndex);
                    traces(involvedCells(receiverCell),1:t) = traces(involvedCells(maxIndex),1:t);
                end
            end
        end
    end
    filledTraces = traces;
end