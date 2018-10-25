function [] = createSingleCellMovie(imageSequence, centroids, maxValue, dimensions, outputFile)
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
        subImage = zeros(dimensions(1), dimensions(2));
    else
        centroids(t,1) = round(min(max(centroids(t,1), 1), size(imageSequence,1)));
        centroids(t,2) = round(min(max(centroids(t,2), 1), size(imageSequence,2)));
        position_height = min(max(centroids(t,1) - offset_height, 1), size(imageSequence,1)-dimensions(1));
        position_width = min(max(centroids(t,2) - offset_width, 1), size(imageSequence,2)-dimensions(2));
        
        centroidShift_height = centroids(t,1) - position_height;
        centroidShift_width = centroids(t,2) - position_width;
        
        boundingRectangle = zeros(4,1);
        boundingRectangle(1) = max(centroidShift_height - 25, 1);
        boundingRectangle(2) = max(centroidShift_width - 25, 1);
        boundingRectangle(3) = min(boundingRectangle(1) + 50, dimensions(1));
        boundingRectangle(4) = min(boundingRectangle(2) + 50, dimensions(2));
        binaryMask = zeros(dimensions(1), dimensions(2));
        binaryMask(boundingRectangle(1):boundingRectangle(3), boundingRectangle(2):boundingRectangle(4)) = 1;
        binaryMask = bwperim(binaryMask);
        
        subImage = double(imageSequence(position_height:(position_height + dimensions(1)-1), position_width:(position_width + dimensions(2)-1),t));
        %     subImage = subImage / maxValue;
        %     subImage(subImage > 1) = 1;
        
        % For gray images
        %    subImage = subImage * (2^16 - 1);
        
        % For color images with bounding box
        %     subImage = im2rgb(subImage);
        %     subImage = imoverlay(subImage, binaryMask, [1, 1, 1]);
    end
    imwrite(uint16(subImage), outputFile, 'WriteMode', 'append', 'Compression', 'none');
end
end