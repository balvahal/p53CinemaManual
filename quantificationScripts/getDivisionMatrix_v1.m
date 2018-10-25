function divisionMatrix = getDivisionMatrix(centroidsDivisions)
    trackedCells = centroidsDivisions.getTrackedCellIds;
    divisionMatrix = zeros(length(trackedCells), length(centroidsDivisions.singleCells));
    for i = 1:length(trackedCells)
        currentTrack = centroidsDivisions.getCellTrack(trackedCells(i));
        divisionEvents = find(currentTrack(:,1) > 0);
        if(~isempty(divisionEvents))
            divisionMatrix(i,1:length(divisionEvents)) = divisionEvents;
        end
    end
    maxDivision = max(sum(divisionMatrix > 0, 2));
    divisionMatrix = divisionMatrix(:,1:maxDivision);
end