function LocalMaxima = getImageMaxima(IM)
%IM = imnormalize(log(double(IM)));
BlurredImage = double(imfilter(IM, fspecial('gaussian', 10, 4), 'replicate'));
%BlurredImage = imnormalize(log(double(BlurredImage)));

%% Intensity based local maxima
LocalMaxima = imregionalmax(BlurredImage);
LocalMaxima = bwmorph(LocalMaxima, 'shrink');
% % nbin = 100;
% % % [y,x] = hist(IM(LocalMaxima), nbin);
% % % threshold = x(round(nbin * SEGMENTATION_TriangleMethod(y) * 1));
% % % Objects = BlurredImage > threshold;
% % % 
% % [y,x] = hist(BlurredImage(:), nbin);
% % threshold = x(round(nbin * SEGMENTATION_TriangleMethod(y)));
% % Objects = BlurredImage > threshold;
% 
% 
% Objects = im2bw(BlurredImage, graythresh(BlurredImage));
% Objects = imclose(Objects, strel('disk', 4));
% Objects = imopen(Objects, strel('disk', 4));


%% Shape based local maxima

nbin = 100;
[y,x] = hist(BlurredImage(:), nbin);
threshold = x(round(nbin * SEGMENTATION_TriangleMethod(y) * 1));
Objects = imfill(imopen(BlurredImage > threshold, strel('disk', 4)), 'holes');

EdgeImage = imdilate(edge(BlurredImage, 'canny'), strel('disk', 1));
Objects = Objects | imfill(EdgeImage, 'holes');
%LocalMaxima = bwmorph(imregionalmax(bwdist(~Objects)), 'shrink', 'Inf');

LocalMaxima = LocalMaxima .* Objects;

[y,x] = ind2sub(size(IM), find(LocalMaxima));
LocalMaxima = [y,x];
end