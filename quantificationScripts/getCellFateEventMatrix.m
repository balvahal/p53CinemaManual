function cellFateEventMatrix = getCellFateEventMatrix(centroidsTracks, annotationIndex)
    trackedCells = centroidsTracks.getTrackedCellIds;
    cellFateEventMatrix = NaN * ones(length(trackedCells), length(centroidsTracks.singleCells));
    for t = 1:length(centroidsTracks.singleCells)
        [cellFateValue,validCells] = centroidsTracks.getAnnotations(t, annotationIndex);
        [~, validCells] = ismember(validCells, trackedCells);
        cellFateEventMatrix(validCells,t) = cellFateValue;
    end
end