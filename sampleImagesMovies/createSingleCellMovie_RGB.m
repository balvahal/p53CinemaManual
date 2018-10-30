function imageStrip = createSingleCellMovie_RGB(imageSequence, centroids, maxValue, dimensions, outputFile, colorcode, subColorTraces, outputMode)
%Dimensions: height, width
%Centroids: height, width
offset_height = round(dimensions(1)/2);
offset_width = round(dimensions(2)/2);
if(isempty(maxValue))
    maxValue = double(quantile(imageSequence(:), 0.9975));
end
if(strcmp(outputMode, 'stack'))
    imageStrip = [];
else
    numTimepoints = length(1:size(centroids,1));
    imageStrip = zeros(dimensions(1), dimensions(2)*(numTimepoints) - 1, 3);
end
counter = 1;
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
    binaryMask = zeros(dimensions(1), dimensions(2));
    binaryMask(boundingRectangle(1):boundingRectangle(3), boundingRectangle(2):boundingRectangle(4)) = 1;
    binaryMask = bwperim(binaryMask);
    
    subImage = double(imageSequence(position_height:(position_height + dimensions(1)-1), position_width:(position_width + dimensions(2)-1),t));
    subImage = subImage / maxValue;
    subImage(subImage > 1) = 1;
    
    % For color images 
    subImage = im2rgb(subImage);
    colorMask = ones(size(subImage, 1), size(subImage, 2), 3);
    colorMask(:,:,1) = colorMask(:,:,1) * colorcode(subColorTraces(t),1);
    colorMask(:,:,2) = colorMask(:,:,2) * colorcode(subColorTraces(t),2);
    colorMask(:,:,3) = colorMask(:,:,3) * colorcode(subColorTraces(t),3);
    coloredImage = imblend(subImage, colorMask, 1, 'linear burn');
%     subplot(1,3,1); image(subImage);
%     subplot(1,3,2); image(imblend(subImage, colorMask, 1, 'linear burn'));
%     subplot(1,3,3); image(imblend(colorMask, subImage, 1, 'linear burn'));
    if(strcmp(outputMode, 'stack'))
        imwrite(coloredImage, outputFile, 'WriteMode', 'append', 'Compression', 'none');
    else
        imageStrip(:,counter:(counter+dimensions(2)-1),:) = coloredImage;
        counter = counter + dimensions(2);
    end
end
end