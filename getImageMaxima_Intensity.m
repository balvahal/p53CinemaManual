function LocalMaxima = getImageMaxima_Intensity(IM, blurRadius)

BlurredImage = double(imfilter(IM, fspecial('gaussian', blurRadius, 4), 'replicate'));
nbin = 100;
[y,x] = hist(BlurredImage(:), nbin);
threshold = x(round(nbin * SEGMENTATION_TriangleMethod(y)))  * 1.25;
Objects = imfill(imerode(BlurredImage > threshold, strel('disk', 5)), 'holes');

EdgeImage = imdilate(edge(BlurredImage, 'canny'), strel('disk', 1));
Objects = Objects | imfill(EdgeImage, 'holes');
Objects = imerode(Objects, strel('disk', 2));

BlurredImage(~Objects) = 0;
LocalMaxima = imregionalmax(BlurredImage);
LocalMaxima = bwmorph(LocalMaxima, 'shrink', 'inf');

[y,x] = ind2sub(size(IM), find(LocalMaxima));
LocalMaxima = [y,x];
end