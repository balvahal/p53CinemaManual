function LocalMaxima = getImageMaxima_Shape(IM, blurRadius)

BlurredImage = double(imfilter(IM, fspecial('gaussian', blurRadius, 4), 'replicate'));

nbin = 100;
threshold = SEGMENTATION_TriangleMethod(BlurredImage,0.99)  * 1.25;
Objects = imfill(imerode(BlurredImage > threshold, strel('disk', 5)), 'holes');

EdgeImage = imdilate(edge(IM, 'canny'), strel('disk', 1));
Objects = Objects | imfill(EdgeImage, 'holes');
Objects = imerode(Objects, strel('disk', 4));

%Objects = imerode(imfill(imdilate(edge(BlurredImage, 'Canny', 0.05),strel('disk', 5)), 'holes'), strel('disk', 5));

LocalMaxima = imregionalmax(imfilter(bwdist(~Objects), fspecial('gaussian', blurRadius, 4), 'replicate'));
LocalMaxima = bwmorph(LocalMaxima, 'shrink', 'inf');

[y,x] = ind2sub(size(IM), find(LocalMaxima));
LocalMaxima = [y,x];
end