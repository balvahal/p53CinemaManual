function [singleCells, threshold] = SEGMENTATION_identifyFISHCytoplasm_DAPIsegmented(originalImage, nucleiObjects, defaultThreshold)
% Identify cytoplasmic and background signal. A potential pitfall in this
% part of the code is failure to identify a local minimum when the whole
% field of view is composed of cells. Such limitation could be overcome by
% user defined expected contribution of background pixels to the image.
% 
% localMinima = [];
% bandwidth = 0.005;
% while isempty(localMinima)
%     [y x] = ksdensity(log10(double(originalImage(:))), 'width', bandwidth);
%     [minimaValue, localMinima] = findpeaks(-y);
%     [maximaValue, localMaxima] = findpeaks(y);
%     bandwidth = bandwidth * 0.75;
% end
% 
% [~, loc] = max(maximaValue);
% [loc, ~] = min(localMinima(localMinima > loc));
% threshold = 10^x(loc);
% 
%  [~, localMaxima] = max(y);
%  integratedPeak = cumsum(y((localMaxima+1):length(y)));
%  [~, upperbound] = max(integratedPeak(integratedPeak < sum(y(1:localMaxima))*0.75));
%  upperbound = upperbound + localMaxima;
%  threshold = 10^x(upperbound);

originalImage = adapthisteq(imnormalize(originalImage));
BlurredImage = imfilter(originalImage, fspecial('gaussian', 15, 4));
Intensity = BlurredImage(:);
IQR = quantile(Intensity, [0.001, 0.999]);
Intensity = Intensity(Intensity > IQR(1) & Intensity < IQR(2));
[y,x] = hist(Intensity, 100);
% [~, localMinima] = findpeaks(-y);
% if(~isempty(localMinima))
%     threshold = 10^x(localMinima(1));
% else
%     threshold = defaultThreshold;
% end
threshold = x(round(length(x) * SEGMENTATION_TriangleMethod(y)));
if(threshold > defaultThreshold)
    threshold = defaultThreshold;
end

cytoplasmImage = BlurredImage > threshold;
cytoplasmImage = imfill(cytoplasmImage, 'holes');
cytoplasmImage = imopen(cytoplasmImage, strel('disk', 2));
% Combine the thresholded cytoplasmic signal with the nuclei to conduct a
% nuclei seeded watershedding.
BlurredImage(~cytoplasmImage) = 0;

validNuclei = (cytoplasmImage + nucleiObjects) == 2;

Overlaid = imimposemin(-BlurredImage, validNuclei);
L = watershed(Overlaid);
singleCells = double(cytoplasmImage) .* double(L);

centroids = regionprops(logical(validNuclei), 'Centroid');
centroids = round(reshape([centroids.Centroid], [2,length(centroids)]));
singleCellPerim = bwperim(singleCells);
singleCells = imfill(bwperim(singleCells), [centroids(2,:)',centroids(1,:)']);
singleCells = singleCells & ~singleCellPerim;
singleCells = imdilate(singleCells, strel('disk', 1));

end