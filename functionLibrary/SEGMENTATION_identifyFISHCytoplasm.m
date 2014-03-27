function [singleCells, threshold] = SEGMENTATION_identifyFISHCytoplasm(originalImage, dapiImage, defaultThreshold, imageID)
% Identify nuclei in DAPI channel to get watershed seeds
[nucleiObjects, nucleiSeeds] = SEGMENTATION_identifyPrimaryObjects(dapiImage);

% Identify cytoplasmic and background signal. A potential pitfall in this
% part of the code is failure to identify a local minimum when the whole
% field of view is composed of cells. Such limitation could be overcome by
% user defined expected contribution of background pixels to the image.
BlurredImage = imfilter(originalImage, fspecial('gaussian', 15, 4));
localMinima = [];
bandwidth = 0.005;
while isempty(localMinima)
    [y x] = ksdensity(log10(double(originalImage(:))), 'width', bandwidth);
    [minimaValue, localMinima] = findpeaks(-y);
    [maximaValue, localMaxima] = findpeaks(y);
    bandwidth = bandwidth * 0.75;
end
% [~, loc] = max(maximaValue);
% [loc, ~] = min(localMinima(localMinima > loc));
% threshold = 10^x(loc);

[~, localMaxima] = max(y);
integratedPeak = cumsum(y((localMaxima+1):length(y)));
[~, upperbound] = max(integratedPeak(integratedPeak < sum(y(1:localMaxima))*0.75));
upperbound = upperbound + localMaxima;
threshold = 10^x(upperbound);

if(threshold > defaultThreshold)
    threshold = defaultThreshold;
end

cytoplasmImage = originalImage > threshold;
cytoplasmImage = imfill(cytoplasmImage, 'holes');
cytoplasmImage = imopen(cytoplasmImage, strel('disk', 20));

% Combine the thresholded cytoplasmic signal with the nuclei to conduct a
% nuclei seeded watershedding.
BlurredImage(~cytoplasmImage) = 0;
Overlaid = imimposemin(-BlurredImage, nucleiObjects);
L = watershed(Overlaid);
singleCells = double(cytoplasmImage) .* double(L);

% Make plots for inspection purposes
subplot(2,2,1); plot(10.^x,y); xlabel('Intensity'); ylabel('Density'); 
hold on; plot([threshold, threshold], ylim, 'Color', [0.75 0.75 0.75]);
hold on; plot([defaultThreshold, defaultThreshold], ylim, 'Color', [1 0 0]);
hold off;
subplot(2,2,2); imagesc(-originalImage); colormap('gray'); 
    title(texlabel(imageID, 'literal'), 'FontWeight','bold');
end