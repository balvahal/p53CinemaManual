function [ObjectsLabeled, MaximaImage] = SEGMENTATION_identifyPrimaryObjects(OriginalImage)
    %OriginalImage = imfilter(OriginalImage, fspecial('gaussian', 15, 4));
    % Find a valley in the kernel density profile to define threshold
    
%     localMinima = [];
%     bandwidth = 0.05;
%     while isempty(localMinima)
%         [y x] = ksdensity(log10(double(OriginalImage(:))), 'width', bandwidth);
%         [~, localMinima] = findpeaks(-y);
%         [~, localMaxima] = findpeaks(y);
%         bandwidth = bandwidth * 0.75;
%     end
%     [value localMaxima] = findpeaks(y);
%     [~, index] = max(value);
%     [~, index] = min(localMinima(localMinima > localMaxima(index)));
%     objectThreshold = 10^(x(localMinima(index)));
%     Objects = OriginalImage > objectThreshold;
    
    OriginalImage_normalized = imnormalize(double(OriginalImage));
    threshold = SEGMENTATION_TriangleMethod(hist(OriginalImage_normalized(:), 100));
    Objects = im2bw(OriginalImage_normalized, threshold);
    Objects = imopen(Objects, strel('disk', 10));
    minDiameter = 10;
    imResizeFactor = 10/minDiameter;
    
    % Identify maxima in the distance transformed binary image
    DistanceTransformedImage = bwdist(~Objects);
    ResizedDistanceTransformedImage = imresize(DistanceTransformedImage, imResizeFactor, 'bilinear');
    MaximaSuppressionSize = 5; 
    MaximaMask = getnhood(strel('disk', MaximaSuppressionSize));
    ResizedDistanceTransformedImage = ResizedDistanceTransformedImage + 0.001*rand(size(ResizedDistanceTransformedImage));
    MaximaImage = ones(size(ResizedDistanceTransformedImage));
    MaximaImage(ResizedDistanceTransformedImage < ordfilt2(ResizedDistanceTransformedImage,sum(MaximaMask(:)),MaximaMask)) = 0;

    MaximaImage = imresize(MaximaImage, size(OriginalImage), 'bilinear');
    MaximaImage(~Objects) = 0;
    MaximaImage = bwmorph(MaximaImage,'shrink',inf);
    % Use watersheds to segment the binary image
    Overlaid = imimposemin(-DistanceTransformedImage,MaximaImage);
    WatershedBoundaries = watershed(Overlaid) > 0;
    Objects = Objects.*WatershedBoundaries;
    ObjectsLabeled = bwlabel(Objects); 
    
end
