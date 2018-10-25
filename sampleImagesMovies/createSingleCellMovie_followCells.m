function [] = createSingleCellMovie_followCells(imageSequence, centroids, maxValue, dimensions, outputFile)
%Dimensions: height, width
%Centroids: height, width
offset_height = round(dimensions(1)/2);
offset_width = round(dimensions(2)/2);
if(isempty(maxValue))
    maxValue = 0;
    for t=1:size(imageSequence,3)
        tempImage = imageSequence(:,:,3);
        tempMax = double(quantile(tempImage(:), 0.9999));
        maxValue = max(maxValue, tempMax);
    end
end
for t=1:size(centroids,1)
    if(centroids(t,1) == 0)
        continue;
    end
    
    centroids(t,1) = max(1, min(round(centroids(t,1)), size(imageSequence,1)));
    centroids(t,2) = max(1, min(round(centroids(t,2)), size(imageSequence,2)));
    
    position_height = min(max(centroids(t,1) - offset_height, 1), size(imageSequence,1)-dimensions(1));
    position_width = min(max(centroids(t,2) - offset_width, 1), size(imageSequence,2)-dimensions(2));
    
    centroidShift_height = centroids(t,1) - position_height;
    centroidShift_width = centroids(t,2) - position_width;
    
    boundingRectangle = zeros(4,1);
    boundingRectangle(1) = max(centroidShift_height - 25, 1);
    boundingRectangle(2) = max(centroidShift_width - 25, 1);
    boundingRectangle(3) = min(boundingRectangle(1) + 50, dimensions(1));
    boundingRectangle(4) = min(boundingRectangle(2) + 50, dimensions(2));
    
    %subImage = double(imageSequence(position_height:(position_height + dimensions(1)-1), position_width:(position_width + dimensions(2)-1),t));
    subImage = double(imageSequence(:,:,t));
    subImage = subImage / maxValue;
    subImage(subImage > 1) = 1;
%     
%     % For gray images
%     subImage = subImage * (2^16 - 1);
    
    % For color images with bounding box
    subImage = im2rgb(subImage);
    
    binaryMask = zeros(dimensions(1), dimensions(2));
    binaryMask = zeros(size(imageSequence,1), size(imageSequence,2));
    binaryMask(centroids(t,1), centroids(t,2)) = 1;
    binaryMask = imdilate(binaryMask, strel('disk', 10));
    binaryMask = bwperim(binaryMask);

    %subImage = imoverlay(subImage, binaryMask, [0.7, 0.7, 0.1]);
    subImage = imoverlay(subImage, binaryMask, [0.7, 0.2, 0.1]);
    
    imwrite(uint16(subImage), outputFile, 'WriteMode', 'append', 'Compression', 'none');
end
end