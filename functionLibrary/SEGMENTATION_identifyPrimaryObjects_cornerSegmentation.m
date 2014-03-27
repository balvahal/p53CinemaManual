function [reportImage] = SEGMENTATION_identifyPrimaryObjects_cornerSegmentation(OriginalImage, varargin)
    defaultMinDiameter = 10;
    defaultImageResizeFactor = 0.5;
    defaultMaximaSuppressionSize = 5;

    p = inputParser;
    p.addRequired('OriginalImage', @isnumeric);
    addOptional(p,'SecondaryImage', @isnumeric);
    addOptional(p,'LocalMaximaType', 'Shape', @ischar);
    addOptional(p,'WatershedTransformImageType', 'Distance', @ischar)
    addOptional(p,'MinDiameter', defaultMinDiameter, @isnumeric)
    addOptional(p,'ImageResizeFactor', defaultImageResizeFactor, @isnumeric)
    addOptional(p,'MaximaSuppressionSize', defaultMaximaSuppressionSize, @isnumeric)
    p.parse(OriginalImage, varargin{:});
    
    MinDiameter = p.Results.MinDiameter;
    ImageResizeFactor = p.Results.ImageResizeFactor;
    MaximaSuppressionSize = p.Results.MaximaSuppressionSize; 
    MaximaMask = getnhood(strel('disk', MaximaSuppressionSize));
    
    OriginalImage_normalized = imnormalize(double(OriginalImage));
    SizeOfSmoothingFilter=MinDiameter;
    BlurredImage = imfilter(OriginalImage_normalized, fspecial('gaussian', round(SizeOfSmoothingFilter), round(SizeOfSmoothingFilter/3.5)));

    %threshold = SEGMENTATION_TriangleMethod(hist(BlurredImage(:), 100));
    %Objects = im2bw(BlurredImage, threshold);    
    Objects = logical(im2bw(OriginalImage_normalized, graythresh(BlurredImage)) + edge(OriginalImage_normalized, 'canny'));
    Objects = imfill(Objects, 'holes');
    Objects = imopen(Objects, strel('disk', 3));
    Objects = imclose(Objects, strel('disk', 2));
    
    ObjectsLabeled = bwconncomp(Objects);
    ObjectsConvex = bwconvhull(Objects, 'objects');
    DistanceTransformedConvex = bwdist(~ObjectsConvex);
    
    C = corner(Objects, 200);
    corners = sub2ind(size(Objects), C(:,2), C(:,1));
    cornerImage = zeros(size(Objects));
    cornerImage(corners) = 1;
    cornerImage(corners(DistanceTransformedConvex(corners) < 4)) = 0;
    imagesc(imdilate(cornerImage, strel('square', 2)));
    
    reportImage = imoverlay(adapthisteq(OriginalImage_normalized), bwperim(Objects), [0.3, 1, 0.3]);
    reportImage = imoverlay(reportImage, imdilate(cornerImage, strel('square', 5)), [1, 0.3, 0.3]);
    imshow(reportImage);
    
%     % IDENTIFY LOCAL MAXIMA IN THE INTENSITY OF DISTANCE TRANSFORMED IMAGE    
%     if strcmp(p.Results.LocalMaximaType, 'Intensity')
%         if(~isempty(p.Results.SecondaryImage))
%             BlurredImage = imnormalize(OriginalImage) + imnormalize(p.Results.SecondaryImage);
%             BlurredImage = imfilter(BlurredImage, fspecial('gaussian', round(SizeOfSmoothingFilter), round(SizeOfSmoothingFilter/3.5)));
%         end
%         ResizedBlurredImage = imresize(BlurredImage,ImageResizeFactor,'bilinear');
%         MaximaImage = ResizedBlurredImage;
%         MaximaImage(ResizedBlurredImage < ordfilt2(ResizedBlurredImage,sum(MaximaMask(:)),MaximaMask)) = 0;
%         MaximaImage = imresize(MaximaImage,size(BlurredImage),'bilinear');
%         MaximaImage(~Objects) = 0;
%         %imshow(imoverlay(OriginalImage_normalized, bwperim(Objects) + imdilate(MaximaImage, strel('disk', 1)), [0.3 1 0.3]))
%         MaximaImage = bwmorph(MaximaImage,'shrink',inf);
%     else
%         DistanceTransformedImage = bwdist(~Objects, 'euclidean');
%         DistanceTransformedImage = DistanceTransformedImage + 0.001*rand(size(DistanceTransformedImage));
%         ResizedDistanceTransformedImage = imresize(DistanceTransformedImage,ImageResizeFactor,'bilinear');
%         MaximaImage = ones(size(ResizedDistanceTransformedImage));
%         MaximaImage(ResizedDistanceTransformedImage < ordfilt2(ResizedDistanceTransformedImage,sum(MaximaMask(:)),MaximaMask)) = 0;
%         MaximaImage = imresize(MaximaImage,size(Objects),'bilinear');
%         MaximaImage(~Objects) = 0;
%         MaximaImage = bwmorph(MaximaImage,'shrink',inf);
%     end
%     
%     %GENERATE WATERSHEDS TO SEPARATE TOUCHING NUCLEI
%     if strcmp(p.Results.WatershedTransformImageType,'Intensity')
%         %%% Overlays the objects markers (maxima) on the inverted original image so
%         %%% there are black dots on top of each dark object on a white background.
%         Overlaid = imimposemin(-BlurredImage,MaximaImage);
%     else
%         if ~exist('DistanceTransformedImage','var')
%             DistanceTransformedImage = bwdist(~Objects);
%         end
%         Overlaid = imimposemin(-DistanceTransformedImage,MaximaImage);
%     end
%     
%     WatershedBoundaries = watershed(Overlaid) > 0;
%     Objects = Objects.*WatershedBoundaries;
%     ObjectsLabeled = bwlabel(Objects); 
%     ObjectsLabeled = imfill(ObjectsLabeled, 'holes');
end
