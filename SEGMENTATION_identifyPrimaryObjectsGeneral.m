%% SEGMENTATION_identifyPrimaryObjectsGeneral
% An image is segmented.
%
%   [ObjectsLabeled] =
%   SEGMENTATION_identifyPrimaryObjectsGeneral(OriginalImage, varargin)
%
%%% Input
% * OriginalImage: a string. The path to the SuperMDA database file.
% * varargin: a string. The path to the directory containing the image
% files.
%%% |varargin| Parameters
% * LocalMaximaType: _Shape_ or _Intensity_; *Shape* 1. Threshold Image, 2.
% Distance Transform, 3. Find local maxima; *Intensity* 1. Smooth Image, 2.
% Find local maxima.
% * WatershedTransformImageType: *Distance* 1. Threshold Image, 2. Distance
% Transform, 3. Watershed; *Intensity* 1. Smooth Image, 2. Watershed
% * MinDiameter: The size of the smoothing filter used for the _Intensity_
% operations.
% * ImageResizeFactor: Images can be reduced in size in order to speed up
% the image processing. Fewer pixels = fewer operations = fewer seconds.
% * MaximaSuppressionSize: If two maxima are within this distance then they
% are merged into 1.
% * SolidityThreshold: The solidity of an object is a measure of roundness.
% A threshold identify the most cell-like objects.
% * AreaThreshold: Remove objects smaller than this number. The units are
% pixels.
% * MinimumThreshold: This is the minimum possible value of the threshold.
% This is important when an empty image is analyzed.
%
%%% Output:
% * ObjectsLabeled: a labeled image, in which each cell is identified with
% a unique number higher than 0. This is typically an 8-bit image file
% (which holds 255 unique cells).
%
%%% Detailed Description
% There is no detailed description.
%
%%% Other Notes
% It is assumed that the origin is in the ULC and _x_ increases from left
% to right and _y_ increases from top to bottom.
function [ObjectsLabeled, Centroids] = SEGMENTATION_identifyPrimaryObjectsGeneral(OriginalImage, varargin)
%% Parse Input
% and initilize and allocate memory for variables
defaultMinDiameter = 25;
defaultImageResizeFactor = 0.25;
defaultMaximaSuppressionSize = 10;
defaultSolidityThreshold = 0.95;
defaultAreaThreshold = 100;
defaultMinimumThreshold = 0.01;

p = inputParser;
p.addRequired('OriginalImage', @isnumeric);
addOptional(p,'LocalMaximaType', 'Shape', @(x) any(strcmp(x,{'Shape','Intensity'})));
addOptional(p,'KnownCentroids', @isnumeric);
addOptional(p,'WatershedTransformImageType', 'Distance', @(x) any(strcmp(x,{'Distance','Intensity'})))
addOptional(p,'MinDiameter', defaultMinDiameter, @isnumeric)
addOptional(p,'ImageResizeFactor', defaultImageResizeFactor, @isnumeric)
addOptional(p,'MaximaSuppressionSize', defaultMaximaSuppressionSize, @isnumeric)
addOptional(p,'SolidityThreshold', defaultSolidityThreshold, @isnumeric)
addOptional(p,'AreaThreshold', defaultAreaThreshold, @isnumeric)
addOptional(p,'MinimumThreshold', defaultMinimumThreshold, @isnumeric)
p.parse(OriginalImage, varargin{:});

MinDiameter = p.Results.MinDiameter;
ImageResizeFactor = p.Results.ImageResizeFactor;
MaximaSuppressionSize = p.Results.MaximaSuppressionSize;
MinimumThreshold = p.Results.MinimumThreshold;

OriginalImage_medianFilter = medfilt2(OriginalImage, [2,2]);
OriginalImage_normalized = imnormalize(double(OriginalImage_medianFilter));
SizeOfSmoothingFilter=MinDiameter;
BlurredImage = imfilter(OriginalImage_normalized, fspecial('gaussian', round(SizeOfSmoothingFilter), round(SizeOfSmoothingFilter/3.5)), 'replicate');

%% THRESHOLDING
%
ThresholdedImage = imfill(BlurredImage > MinimumThreshold, 'holes');
edgeImage = imfill(imdilate(edge(OriginalImage, 'canny'), strel('disk', 2)), 'holes');
edgeImage = imerode(edgeImage, strel('disk', 2));
% ObjectsLabeled = bwlabel(edgeImage);
% props = regionprops(ObjectsLabeled, 'Solidity');
% primarySegmentation = ismember(ObjectsLabeled, find([props.Solidity] >= p.Results.SolidityThreshold));

% Option 1: only edge image
% Objects = edgeImage;
% Option 2: complement with intensity based thresholding
Objects = imfill((OriginalImage > SEGMENTATION_TriangleMethod(OriginalImage, 1)), 'holes');
Objects = imfill(im2bw(OriginalImage, graythresh_dynamicRange(OriginalImage)), 'holes');
Objects = (Objects & ThresholdedImage) | edgeImage;

%Objects = Objects & ~imdilate(primarySegmentation,strel('disk',2)) & ThresholdedImage; 
%Objects = imopen(Objects, strel('disk',2));
primarySegmentation = zeros(size(Objects));

% FIRST-TIER OBJECT: Keep round objects as they are to avoid
% over-segmenting
ObjectsLabeled = bwlabel(Objects);
props = regionprops(ObjectsLabeled, 'Solidity', 'Area');
Objects = imfill(ismember(ObjectsLabeled, find([props.Area] >= p.Results.AreaThreshold)), 'holes');
primarySegmentation = primarySegmentation | ismember(ObjectsLabeled, find([props.Solidity] >= p.Results.SolidityThreshold & [props.Area] >= p.Results.AreaThreshold));

% Optional for certain cell lines: filter out objects that look like beans
% and keep them as they are to avoid over-segmentation.

%     ObjectsLabeled = bwlabel(Objects); beanshapes = zeros(1,
%     length(props)); props = regionprops(ObjectsLabeled, 'FilledImage');
%     for k=1:length(props)
%         convexHull = bwconvhull(props(k).FilledImage) &
%         ~props(k).FilledImage; convexHull = imopen(convexHull,
%         strel('square', 3)); components = bwconncomp(convexHull);
%         beanshapes(k) = components.NumObjects;
%     end primarySegmentation = primarySegmentation |
%     ismember(ObjectsLabeled, find(beanshapes < 2));

% REFINE PARAMETERS: Use information about primary segmentation to inform
% selection of smoothing filter and maxima suppression size for watershed
% segmentation.
if(sum(primarySegmentation(:)) > 0)
    props = bwconncomp(primarySegmentation);
    SizeOfSmoothingFilter = round(2 * sqrt(median(cellfun(@length, props.PixelIdxList))) / pi);
    MaximaSuppressionSize = round(0.2 * SizeOfSmoothingFilter);
end

MaximaMask = getnhood(strel('disk', MaximaSuppressionSize));

Objects = Objects & ~primarySegmentation;
BlurredImage(~Objects) = 0;

if(sum(logical(Objects(:))) > 0)
    %%% IDENTIFY LOCAL MAXIMA IN THE INTENSITY OF DISTANCE TRANSFORMED IMAGE
    %
    if strcmp(p.Results.LocalMaximaType, 'Intensity')
        BlurredImage = imfilter(OriginalImage_normalized, fspecial('gaussian', round(SizeOfSmoothingFilter), round(SizeOfSmoothingFilter/3.5)));
        BlurredImage(~Objects) = 0;
        
        ResizedBlurredImage = imresize(BlurredImage,ImageResizeFactor,'bilinear');
        MaximaImage = ResizedBlurredImage;
        MaximaImage(ResizedBlurredImage < ordfilt2(ResizedBlurredImage,sum(MaximaMask(:)),MaximaMask)) = 0;
        MaximaImage = imresize(MaximaImage,size(BlurredImage),'bilinear');
        MaximaImage(~Objects) = 0;
        MaximaImage = bwmorph(MaximaImage,'shrink',inf);
    else
        DistanceTransformedImage = bwdist(~Objects, 'euclidean');
        DistanceTransformedImage = DistanceTransformedImage + 0.001*rand(size(DistanceTransformedImage));
        ResizedDistanceTransformedImage = imresize(DistanceTransformedImage,ImageResizeFactor,'bilinear');
        MaximaImage = ones(size(ResizedDistanceTransformedImage));
        MaximaImage(ResizedDistanceTransformedImage < ordfilt2(ResizedDistanceTransformedImage,sum(MaximaMask(:)),MaximaMask)) = 0;
        MaximaImage = imresize(MaximaImage,size(Objects),'bilinear');
        MaximaImage(~Objects) = 0;
        MaximaImage = bwmorph(MaximaImage,'shrink',inf);
    end
    
    %%% GENERATE WATERSHEDS TO SEPARATE TOUCHING NUCLEI
    %
    if strcmp(p.Results.WatershedTransformImageType,'Intensity')
        %%% Overlays the objects markers (maxima) on the inverted original
        %%% image so there are black dots on top of each dark object on a
        %%% white background.
        Overlaid = imimposemin(-BlurredImage,MaximaImage);
    else
        if ~exist('DistanceTransformedImage','var')
            DistanceTransformedImage = bwdist(~Objects);
        end
        Overlaid = imimposemin(-DistanceTransformedImage,MaximaImage);
    end
    
    WatershedBoundaries = watershed(Overlaid) > 0;
    Objects = Objects.*WatershedBoundaries | logical(primarySegmentation);
    ObjectsLabeled = bwlabel(Objects);
else
    ObjectsLabeled = bwlabel(primarySegmentation);
end

%props = regionprops(ObjectsLabeled, 'Area');
%ObjectsLabeled = ObjectsLabeled .* ismember(ObjectsLabeled, find([props.Area] >= p.Results.AreaThreshold));
%ObjectsLabeled = bwlabel(ObjectsLabeled);
Centroids = regionprops(ObjectsLabeled, 'Centroid');
Centroids = reshape([Centroids.Centroid],2,length(Centroids))';
end
