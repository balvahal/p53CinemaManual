function divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions)
    trackedCells = centroidsTracks.getTrackedCellIds;
    divisionMatrix = zeros(length(trackedCells), length(centroidsDivisions.singleCells));
    for t = 1:length(centroidsDivisions.singleCells)
        [~, validCells] = centroidsDivisions.getCentroids(t);
        [~, validCells] = ismember(validCells, trackedCells);
        divisionMatrix(validCells,t) = 1;
    end
end