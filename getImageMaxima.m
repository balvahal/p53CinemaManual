function LocalMaxima = getImageMaxima(IM)
IM = double(IM);
BlurredImage = imfilter(IM, fspecial('gaussian', 5, 4), 'replicate');
LocalMaxima = imregionalmax(BlurredImage);
LocalMaxima = bwmorph(LocalMaxima, 'shrink');

nbin = 100;
[y,x] = hist(IM(LocalMaxima), nbin);
threshold = x(round(nbin * SEGMENTATION_TriangleMethod(y) * 0.5));

LocalMaxima = LocalMaxima .* (BlurredImage > threshold);
[y,x] = ind2sub(size(IM), find(LocalMaxima));
LocalMaxima = [y,x];
end