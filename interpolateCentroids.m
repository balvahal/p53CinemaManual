function annotation = interpolateCentroids(annotation, startIndex, skipIndex)
    for i=startIndex:(skipIndex+1):(length(annotation) - skipIndex - 1)
        anchorCells = find(annotation(i).point(:,1) > 0);
        for j=1:length(anchorCells)
            thisCell = anchorCells(j);
            if(annotation(i+skipIndex+1).point(thisCell,1) > 0)
                for k=1:skipIndex
                    annotation(i+k).point(thisCell,:) = round((annotation(i).point(thisCell,:) + annotation(i+skipIndex+1).point(thisCell,:))/(skipIndex+1));
                end
            end
        end
    end
end