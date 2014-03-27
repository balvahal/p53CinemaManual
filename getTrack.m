function centroids = getTrack(singleCellTracks, id)
    centroids = zeros(length(singleCellTracks),2);
    for i=1:length(singleCellTracks)
        centroids(i,:) = singleCellTracks(i).point(id,:);
    end
end
