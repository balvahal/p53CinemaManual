function ObjectsLabeled = singleCellFollowing_imageProcessing_localMaxima(IM)
% SizeOfSmoothingFilter = 15;
% MaximaSuppressionSize = 10;
% MaximaMask = getnhood(strel('disk', MaximaSuppressionSize));
% 
% BlurredImage = imfilter(IM, fspecial('gaussian', SizeOfSmoothingFilter, 4), 'replicate');
% thresholdedImage = im2bw(BlurredImage, graythresh(BlurredImage) * 0.3);
% 
% BlurredImage(~thresholdedImage) = 0;
% 
% MaximaImage = ones(size(BlurredImage));
% MaximaImage(BlurredImage < ordfilt2(BlurredImage,sum(MaximaMask(:)),MaximaMask)) = 0;
% MaximaImage = bwmorph(MaximaImage,'shrink',inf);
%     
% MaximaImage = imdilate(MaximaImage, strel('disk', 2));
% ObjectsLabeled = bwlabel(MaximaImage);
edgeImage = edge(IM, 'canny');
end