function filledTraces = fillLineageInformation(traces, centroidsDivisions)
    for t=1:length(centroidsDivisions.singleCells)
        [divisions, dividing_cells] = centroidsDivisions.getCentroids(t);
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
                    traces(dividing_cells(involvedCells(receiverCell)),1:t) = traces(dividing_cells(involvedCells(maxIndex)),1:t);
                end
            end
        end
    end
    filledTraces = traces;
end