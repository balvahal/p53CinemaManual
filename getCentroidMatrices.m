function [centroid_col_mat, centroid_row_mat] = getCentroidMatrices(centroidsTracks)
    trackedCells = centroidsTracks.getTrackedCellIds;
    centroid_col_mat = zeros(length(trackedCells), length(centroidsTracks.singleCells));
    centroid_row_mat = centroid_col_mat;
    for i=1:length(trackedCells)
        singleCellTrack = centroidsTracks.getCellTrack(trackedCells(i));
        centroid_col_mat(i,:) = singleCellTrack(:,1);
        centroid_row_mat(i,:) = singleCellTrack(:,2);
    end
end