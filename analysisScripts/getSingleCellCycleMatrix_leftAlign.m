function cellCycles = getSingleCellCycleMatrix_leftAlign(traces, divisions, numCycles)
    maxCells = sum(divisions(:));
    divisionTiming = getDivisionTiming(divisions);
    cellCycleLength = divisionTiming(:,2:end) - divisionTiming(:,1:(end-1));
    maxCellCycleLength = max(cellCycleLength(cellCycleLength > 0));
    
    cellCycles = -ones(maxCells, (maxCellCycleLength+1)*numCycles);
    counter = 1;
    for i=1:size(traces,1)
        divisionEvents = find(divisions(i,:));
        if(length(divisionEvents) > numCycles)
            for j=1:(length(divisionEvents)-numCycles)
                subTrace = traces(i,divisionEvents(j):divisionEvents(j+numCycles));
                cellCycles(counter,1:length(subTrace)) = subTrace;
                %cellCycles(counter,(end-length(subTrace)+1):end) = subTrace;
                counter = counter + 1;
            end
        end
    end
    cellCycles = cellCycles(1:(counter-1),:);
end