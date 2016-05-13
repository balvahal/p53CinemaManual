function LocalMaxima = getImageMaxima(IM, blurRadius)

%IM = imnormalize(log(double(IM)));
%IM = log(double(IM + 1));
%IM = medfilt2(IM, [4,4]);
BlurredImage = double(imfilter(IM, fspecial('gaussian', blurRadius, 4), 'replicate'));
%BlurredImage = imnormalize(log(double(BlurredImage)));

%% Intensity based local maxima

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
threshold = x(round(nbin * SEGMENTATION_TriangleMethod(y,1)))  * 1.25;
Objects = imfill(imerode(BlurredImage > threshold, strel('disk', 5)), 'holes');

EdgeImage = imdilate(edge(BlurredImage, 'canny'), strel('disk', 1));
Objects = Objects | imfill(EdgeImage, 'holes');
Objects = imerode(Objects, strel('disk', 2));
%LocalMaxima = bwmorph(imregionalmax(bwdist(~Objects)), 'shrink', 'Inf');

%BlurredImage(~Objects) = 0;
% LocalMaxima = imregionalmax(BlurredImage);
% LocalMaxima = bwmorph(LocalMaxima, 'shrink', 'inf');

%LocalMaxima = LocalMaxima .* Objects;

LocalMaxima = imregionalmax(imfilter(bwdist(~Objects), fspecial('gaussian', blurRadius, 4), 'replicate'));
LocalMaxima = bwmorph(LocalMaxima, 'shrink', 'inf');

[y,x] = ind2sub(size(IM), find(LocalMaxima));
LocalMaxima = [y,x];
end