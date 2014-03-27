function [offset, correlation, image] = imstitch2d(im1, im2, isHorizontal)
    if(~isHorizontal)
        temp = im1';
        im1 = im2';
        im2 = temp;
    end

    width = size(im2,2);
    height = size(im2,1);
    minimumOverlap = min((height - 200), size(im1,1)-200);
    trimming = (height - minimumOverlap)/2;
    im2SubImage = im2(trimming:(height-trimming),:);
    minimumOverlap = size(im2SubImage,1);

    potentialOffsetsX = 20:(size(im2,2)/2);
    potentialOffsetsY = 1:(size(im2,1)-size(im2SubImage,1));
    
    correlation = zeros(length(potentialOffsetsY), length(potentialOffsetsX));
    
    for i=1:length(potentialOffsetsX)
        offsetX = potentialOffsetsX(i);
        for j=1:length(potentialOffsetsY)
            offsetY = potentialOffsetsY(j);
            slice1 = im1(offsetY:(offsetY+minimumOverlap-1),(size(im1,2)-offsetX+1):size(im1,2));
            slice2 = im2SubImage(:,1:offsetX);
            correlation(j,i) = corr(slice1(:), slice2(:));
        end
    end
    [~, locY] = max(max(correlation'));
    [~, locX] = max(max(correlation));
    offset = [potentialOffsetsY(locY)- trimming, potentialOffsetsX(locX)];
    
    im1Trimmed = im1(offset(1):height,1:(width-offset(2)));
    im2Trimmed = im2(1:(height-offset(1)+1),:);
    image = horzcat(im1Trimmed, im2Trimmed);
    
    if(~isHorizontal)
        image = image';
    end
    
end