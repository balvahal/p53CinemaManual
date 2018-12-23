function LocalMaxima = getImageMaxima_Intensity(IM, blurRadius)

BlurredImage = double(imfilter(IM, fspecial('gaussian', blurRadius, 4), 'replicate'));
threshold = SEGMENTATION_TriangleMethod(BlurredImage,0.99)  * 1.5;
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