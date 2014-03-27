function [offset, correlation, image] = imstitch2d(im1, im2, isHorizontal)
    if(~isHorizontal)
        temp = im1';
        im1 = im2';
        im2 = temp;
    end
    
    % Generate a subimage that will serve as a mask for scanning in the y
    % direction
    targetTrimming = size(im2,1) * 0.2; % Percentage
    minimumOverlap = uint16(min(size(im1,1) - targetTrimming, size(im2,1)-targetTrimming));
    trimming = (size(im2,1) - minimumOverlap)/2;
    im2SubImage = im2(trimming:(size(im2,1)-trimming),:);
    minimumOverlap = size(im2SubImage,1);

    potentialOffsetsX = 1:(size(im1,2)/8);
    potentialOffsetsY = 1:(size(im1,1)-size(im2SubImage,1));
    
    correlation = zeros(length(potentialOffsetsY), length(potentialOffsetsX));
    
    progress = 0;
    for i=1:length(potentialOffsetsX)
        if(i/length(potentialOffsetsX) > progress)
            fprintf('%d ', uint16(progress * 100));
            progress = progress + 0.1;
        end
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
    offset = [potentialOffsetsY(locY), potentialOffsetsX(locX)];
    
    % The cropping vector contains the coordinates in the following format:
    % [x, y, width, height]
    cropping1(2) = max(1, offset(1) - trimming);
    cropping2(2) = max(1, trimming - offset(1));
    cropping1(1) = 1;
    cropping2(1) = 1;
    
    finalHeight = min(size(im1,1) - cropping1(2) + 1, size(im2,1) - cropping2(2) + 1);
    cropping1(4) = finalHeight;
    cropping2(4) = finalHeight;
    cropping1(3) = size(im1,2)-offset(2);
    cropping2(3) = size(im2,2);
    
    im1Trimmed = imsubimage(im1, cropping1);
    im2Trimmed = imsubimage(im2, cropping2);
    image = horzcat(im1Trimmed, im2Trimmed);
    
    offset = {cropping1, cropping2};
    
    if(~isHorizontal)
        image = image';
    end
    
end