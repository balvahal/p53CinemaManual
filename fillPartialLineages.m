function expandedMatrix = fillPartialLineages(traces_nonRedundant, filledTraces, divisions_nonRedundant, filledDivisions, level)
    expandedMatrix = traces_nonRedundant;
    divisionTiming = getDivisionTiming(divisions_nonRedundant);
    filledDivisionTiming = getDivisionTiming(filledDivisions);
    
    for i=1:size(expandedMatrix,1)
        currentLimit = divisionTiming(i,1);
        newLimit = filledDivisionTiming(i,max(find(filledDivisionTiming(i,:) == currentLimit)-level+1,1));
        if(newLimit > 0)
            expandedMatrix(i,newLimit:end) = filledTraces(i,newLimit:end);
        end
    end
end