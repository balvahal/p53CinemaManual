function [ObjectsLabeled, MaximaImage] = SEGMENTATION_identifyPrimaryObjectsGeneral_maximaStrategy(OriginalImage, LocalMaximaType, WatershedTransformImageType)
    MinDiameter = 10;
    ImageResizeFactor = 10/MinDiameter;
    MaximaSuppressionSize = 4; 
    MaximaMask = getnhood(strel('disk', MaximaSuppressionSize));
    
    OriginalImage_normalized = imnormalize(double(OriginalImage));
    OriginalImage_normalized = imfilter(OriginalImage_normalized, fspecial('gaussian', 15, 4));
    
    %% Find local maxima in blurred image
    SizeOfSmoothingFilter=25;
    BlurredImage = imfilter(OriginalImage_normalized, fspecial('gaussian', round(SizeOfSmoothingFilter), round(SizeOfSmoothingFilter/3.5)));
    maximaImage = imdilate(imregionalmax(BlurredImage), strel('disk', 3));
    maximaPixels = BlurredImage(maximaImage);
    % Filter true maxima with an intensity-based threshold
    [y,x] = ksdensity(log10(maximaPixels(:)));
    [~,localMinima] = findpeaks(-y);
    maximaThreshold = 10^x(localMinima(1));
    maximaImage = maximaImage & BlurredImage > maximaThreshold;
    maximaImage2 = imdilate(maximaImage, strel('disk', 25));
    overlayImage = imoverlay(im2rgb(BlurredImage), maximaImage, [3 0 0]);
    imshow(overlayImage);
    
    %% Perform local thresholding in watershed image
    landscapeImage = imimposemin(-OriginalImage, maximaImage);
    L = bwlabel(maximaImage2 .* (watershed(landscapeImage) > 0));
    ObjectIndex = regionprops(L, 'PixelIdxList', 'BoundingBox', 'Solidity');
    OriginalFlat = double(OriginalImage(:));
    Objects = zeros(size(OriginalImage,1), size(OriginalImage,2));
    for i=1:length(ObjectIndex)
        coord = floor(ObjectIndex(i).BoundingBox);
        coord(coord == 0) = 1;
        subImage = OriginalImage(coord(2):(coord(2)+coord(4)), coord(1):(coord(1)+coord(3)));
        edgeImage = edge(subImage, 'canny');
        edgeImage = imclose(edgeImage, strel('disk', 2));
        edgeImage = imfill(edgeImage, 'holes');
        edgeImage = imopen(edgeImage, strel('disk', 3));
        subObjects = regionprops(logical(edgeImage), 'PixelIdxList', 'Solidity');
        if(~isempty(subObjects))
            objectSize = cellfun(@length, {subObjects(:).PixelIdxList});
            [~,selected] = max(objectSize);
            mask = zeros(1,numel(subImage));
            mask(subObjects(selected).PixelIdxList) = subObjects(selected).Solidity;
            mask = reshape(mask, size(subImage));
            Objects(coord(2):(coord(2)+coord(4)), coord(1):(coord(1)+coord(3))) = Objects(coord(2):(coord(2)+coord(4)), coord(1):(coord(1)+coord(3))) | mask;
        end
    end
    
    %threshold = SEGMENTATION_TriangleMethod(hist(BlurredImage(:), 100));
    Objects = im2bw(BlurredImage, threshold);    
    Objects = imopen(Objects, strel('disk', 2));
    
    % IDENTIFY LOCAL MAXIMA IN THE INTENSITY OF DISTANCE TRANSFORMED IMAGE    
    if strcmp(LocalMaximaType, 'Intensity')
        ResizedBlurredImage = imresize(BlurredImage,ImageResizeFactor,'bilinear');
        MaximaImage = ResizedBlurredImage;
        MaximaImage(ResizedBlurredImage < ordfilt2(ResizedBlurredImage,sum(MaximaMask(:)),MaximaMask)) = 0;
        MaximaImage = imresize(MaximaImage,size(BlurredImage),'bilinear');
        MaximaImage(~Objects) = 0;
        MaximaImage = bwmorph(MaximaImage,'shrink',inf);
    else
        DistanceTransformedImage = bwdist(~Objects);
        DistanceTransformedImage = DistanceTransformedImage + 0.001*rand(size(DistanceTransformedImage));
        ResizedDistanceTransformedImage = imresize(DistanceTransformedImage,ImageResizeFactor,'bilinear');
        MaximaImage = ones(size(ResizedDistanceTransformedImage));
        MaximaImage(ResizedDistanceTransformedImage < ordfilt2(ResizedDistanceTransformedImage,sum(MaximaMask(:)),MaximaMask)) = 0;
        MaximaImage = imresize(MaximaImage,size(Objects),'bilinear');
        MaximaImage(~Objects) = 0;
        MaximaImage = bwmorph(MaximaImage,'shrink',inf);
    end
    
    %GENERATE WATERSHEDS TO SEPARATE TOUCHING NUCLEI
    if strcmp(WatershedTransformImageType,'Intensity')
        %%% Overlays the objects markers (maxima) on the inverted original image so
        %%% there are black dots on top of each dark object on a white background.
        Overlaid = imimposemin(-BlurredImage,MaximaImage);
    elseif strcmp(WatershedTransformImageType,'Distance')
        if ~exist('DistanceTransformedImage','var')
            DistanceTransformedImage = bwdist(~Objects);
        end
        Overlaid = imimposemin(-DistanceTransformedImage,MaximaImage);
    end
    
    WatershedBoundaries = watershed(Overlaid) > 0;
    Objects = Objects.*WatershedBoundaries;
    ObjectsLabeled = bwlabel(Objects); 
    ObjectsLabeled = imfill(ObjectsLabeled, 'holes');
end
