function [singleCellTracks_foci, singleCellTracks_background, singleCellTracks_dilation] = getSingleCellTrace_fociAnalysis(rawdatapath, segmentationpath, database, group, position, measurementChannel, segmentationChannel, centroids, ff_offset, ff_gain)
trackedCells = centroids.getTrackedCellIds;
numTracks = length(trackedCells);
numTimepoints = length(centroids.singleCells);

singleCellTracks_foci = -ones(numTracks, numTimepoints);
singleCellTracks_background = -ones(numTracks, numTimepoints);
singleCellTracks_dilation = -ones(numTracks, numTimepoints);

progress = 0;
for i=1:numTimepoints
    if(i/numTimepoints * 100 > progress)
        fprintf('%d ', progress);
        progress = progress + 10;
    end
    % Get measurement and segmentation files
    if(~isempty(measurementChannel))
        measurementFile = getDatabaseFile2(database, group, measurementChannel, position, i);
        if(isempty(measurementFile))
            continue;
        end
    else
        measurementFile = [];
    end
    if(~isempty(segmentationChannel))
        segmentFile = getDatabaseFile2(database, group, segmentationChannel, position, i);
    else
        segmentFile = [];
    end
    % Get current centroids
    [currentCentroids, validCells] = centroids.getCentroids(i);
    [~, validCells] = ismember(validCells, trackedCells);
    
    if(isempty(segmentFile) || isempty(validCells))
        continue;
    end
    % Read image and object files
    if(~isempty(measurementFile))
        IntensityImage = double(imread(fullfile(rawdatapath, measurementFile)));
        
        if(~isempty(ff_gain))
            IntensityImage = flatfield_correctImage(IntensityImage, ff_offset, ff_gain);
        end
        
        %IntensityImage = medfilt2(IntensityImage, [2,2]);
        %IntensityImage = imbackground(IntensityImage, 10, 100);
        
        [y,x] = hist(log(IntensityImage(IntensityImage > 0)), 1000);
        x_background = x(find(y == max(y), 1, 'first'));
        IntensityImage = max(0, IntensityImage - exp(x_background));
        IntensityImage_blurred = imfilter(IntensityImage, fspecial('gaussian', 5, 1));

    else
        IntensityImage = [];
        IntensityImage_blurred = [];
    end
    if(~isempty(segmentFile))
        %segmentFile = regexprep(segmentFile, '\.tiff', '_segment.TIF', 'ignoreCase');
        segmentFile = regexprep(segmentFile, '_w\d_*.*?_([st])', '_$1');
        %segmentFile = regexprep(segmentFile, '\..*', '.PNG');
        Objects = double(imread(fullfile(segmentationpath, segmentFile)));
    end

    scalingFactor = 1;
    currentCentroids(:,1) = min(currentCentroids(:,1) * scalingFactor, size(Objects,1));
    currentCentroids(:,2) = min(currentCentroids(:,2) * scalingFactor, size(Objects,2));
    
    measurements1 = regionprops_withKnownCentroids_fun(Objects, IntensityImage_blurred, currentCentroids, @(x) mean(x(x > quantile(x, 0.9))));
    measurements2 = regionprops_withKnownCentroids_fun(Objects, IntensityImage_blurred, currentCentroids, @median);
    singleCellTracks_foci(validCells, i) = measurements1(:,2);
    singleCellTracks_background(validCells, i) = measurements2(:,2);
    
    % Per centroid segmentation and thresholding, from Jacob's script
    siz = 111;
    for j=1:size(currentCentroids,1)
        g=GetBlock(IntensityImage_blurred,currentCentroids(j,2),currentCentroids(j,1),siz);
        g2=GetBlock(IntensityImage,currentCentroids(j,2),currentCentroids(j,1),siz);
        g2=(imfilter(g2,fspecial('gaussian',5,2),'replicate'));
        g2=autoscale(g2);
        g3=g2(floor(siz/2)-5:floor(siz/2)+5,floor(siz/2)-5:floor(siz/2)+5);
        the=median(g3(:));
        the=the-1*mad(g3(:));
        g2=g2>(min(median(g2(:)),graythresh(g2))+the)/2;
        g2=imfill(g2,'holes');
        %                gw=g2.*g2t;
        %                gw=-gw;
        %                gw(g2t==0)=-inf;
        %                gw=-gw;
        %                gw(floor(siz/2)-1:floor(siz/2)+1,floor(siz/2)-1:floor(siz/2)+1)=-inf;
        %g2=autoscale(g2)>graythresh(autoscale(g2));
        
        g2=bwlabel(g2); g2=(g2==g2(floor(siz/2),floor(siz/2)));
        g2=imdilate(g2,strel('disk',3));
        g=g.*g2;
        s=sort(g(:),'descend');
        singleCellTracks_dilation(validCells(j),i)=mean(s(1:min(9,length(s))));     
    end
        
    % Repeated values (divisions, for instance)
    currentCentroids = sub2ind(size(Objects), currentCentroids(:,1), currentCentroids(:,2));
    if(length(currentCentroids) > 1)
        centroidFrequency = tabulate(currentCentroids);
        repeatedValues = centroidFrequency(centroidFrequency(:,2) > 1,1);
        for j=1:length(repeatedValues)
            repeatedIndexes = validCells(currentCentroids == repeatedValues(j));
            singleCellTracks_foci(repeatedIndexes,i) = max(singleCellTracks_foci(repeatedIndexes,i));
            singleCellTracks_background(repeatedIndexes,i) = max(singleCellTracks_background(repeatedIndexes,i));
            singleCellTracks_dilation(repeatedIndexes,i) = max(singleCellTracks_dilation(repeatedIndexes,i));
        end
    end
end
fprintf('\n');
end

function [tim]=GetBlock(im,locX,locY,siz)

    hd=(siz-1)/2;
    tim=im(max(1,locX-hd):min(size(im,1),locX+hd),max(1,locY-hd):min(locY+hd,size(im,2)));

end
