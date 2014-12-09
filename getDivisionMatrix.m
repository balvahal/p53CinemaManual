function divisionMatrix = getDivisionMatrix(centroidsTracks, centroidsDivisions)
    trackedCells = centroidsTracks.getTrackedCellIds;
    divisionMatrix = zeros(length(trackedCells), length(centroidsDivisions.singleCells));
    for t = 1:length(centroidsDivisions.singleCells)
        [~, validCells] = centroidsDivisions.getCentroids(t);
<<<<<<< HEAD
        [~, validCells] = ismember(validCells, trackedCells);
=======
>>>>>>> origin/master
        divisionMatrix(validCells,t) = 1;
    end
end