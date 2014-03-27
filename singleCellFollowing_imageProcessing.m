function [finalSegmentation, localMaxima] = singleCellFollowing_imageProcessing(IM)
IM = double(imnormalize(IM));
IM = imbackground(IM, 20, 50);

BlurredImage = imfilter(IM, fspecial('gaussian', 10, 4), 'replicate');
edgeImage = edge(BlurredImage, 'canny');
clearEdges = imdilate(imfill(imfill(edgeImage, 'holes') ~= edgeImage, 'holes'), strel('disk',2));
edgeImage = edgeImage & ~clearEdges;
edgeImage = imdilate(edgeImage, strel('disk',3));
edgeImage = imfill(edgeImage, 'holes');
edgeImage = imerode(edgeImage, strel('disk', 4));
edgeImage = edgeImage | clearEdges;
%threshold = quantile(BlurredImage(edgeImage), 0.5);
%thresholdedImage = imfill(edgeImage + logical(BlurredImage > threshold), 'holes');
thresholdedImage = imfill(edgeImage + im2bw(BlurredImage, graythresh(BlurredImage)*1.5), 'holes');
thresholdedImage = imopen(thresholdedImage, strel('disk',1));

% BlurredImage = imfilter(IM, fspecial('gaussian', 15, 4), 'replicate');
% edgeImage = edge(BlurredImage, 'canny');
% edgeImage = imdilate(edgeImage, strel('disk',3));
% edgeImage = imfill(edgeImage, 'holes');
% edgeImage = imopen(edgeImage, strel('disk', 4));
% thresholdedImage = edgeImage;

thresholdedImage = bwlabel(thresholdedImage);
props = regionprops(thresholdedImage, 'Solidity');
firstPassSegmentation = ismember(thresholdedImage, find([props.Solidity] > 0.95));
props = regionprops(thresholdedImage, 'Area');
empiricalDiameter = 2*round(sqrt(mean([props.Area])) / pi);
%empiricalDiameter = 10;
thresholdedImage = logical(thresholdedImage) & ~firstPassSegmentation;

if(sum(sum(thresholdedImage))>0)
    IM(~thresholdedImage) = 0;
    BlurredImage(~thresholdedImage) = 0;
    
    secondPassSegmentation = SEGMENTATION_identifyPrimaryObjectsGeneral(IM, ...
        'LocalMaximaType', 'Shape', 'WatershedTransformImageType', 'Intensity', ...
        'MaximaSuppressionSize', 7, 'ImageResizeFactor', 0.25, 'MinDiameter', empiricalDiameter);
    
%     localMaxima = imregionalmax(BlurredImage);
%     secondPassSegmentation = double(watershed(imimposemin(-BlurredImage, localMaxima))) .* thresholdedImage;
%     
%     DistanceTransformedImage = bwdist(~thresholdedImage);
%     localMaxima = imregionalmax(DistanceTransformedImage);
%     secondPassSegmentation = double(watershed(imimposemin(-DistanceTransformedImage, localMaxima))) .* thresholdedImage;
    
    finalSegmentation = firstPassSegmentation | (secondPassSegmentation & ~imdilate(firstPassSegmentation, strel('disk',2)));
    finalSegmentation = bwlabel(finalSegmentation);
else
    finalSegmentation = bwlabel(firstPassSegmentation);
end
props = regionprops(finalSegmentation, 'Area');
finalSegmentation = ismember(finalSegmentation, find([props.Area] > 0));
finalSegmentation = bwlabel(finalSegmentation);

end