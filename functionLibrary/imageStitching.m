function [offset, correlation] = imageStitching(im1, im2, horizontal)
    if(~horizontal)
        temp = im1';
        im1 = im2';
        im2 = temp;
    end
    width = size(im2,2);
    potentialOffsets = 20:(width/2);
    correlation = zeros(1, length(potentialOffsets));
    for i=1:length(potentialOffsets)
        offset = potentialOffsets(i);
        horizontalSlice1 = im1(:,(width-offset+1):width);
        horizontalSlice2 = im2(:,1:offset);
        correlation(i) = corr(horizontalSlice1(:), horizontalSlice2(:));
    end
    [~, loc] = max(correlation);
    offset = potentialOffsets(loc);
end