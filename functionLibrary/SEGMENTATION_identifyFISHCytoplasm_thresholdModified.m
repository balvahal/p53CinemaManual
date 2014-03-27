function [singleCells, threshold] = SEGMENTATION_identifyFISHCytoplasm_thresholdModified(cytoplasmImage, nucleiObjects)
% Identify cytoplasmic and background signal. A potential pitfall in this
% part of the code is failure to identify a local minimum when the whole
% field of view is composed of cells. Such limitation could be overcome by
% user defined expected contribution of background pixels to the image.
BlurredImage = imfilter(originalImage, fspecial('gaussian', 15, 4));
% Combine the thresholded cytoplasmic signal with the nuclei to conduct a
% nuclei seeded watershedding.
BlurredImage(~cytoplasmImage) = 0;
Overlaid = imimposemin(-BlurredImage, nucleiObjects);
L = watershed(Overlaid);
singleCells = double(cytoplasmImage) .* double(L);
end