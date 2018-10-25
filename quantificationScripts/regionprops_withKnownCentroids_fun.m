function measurements = regionprops_withKnownCentroids_fun(binaryMask, intensityImage, centroids, myfun)
%Centroids is in row,col (y,x) format    
centroids(:,1) = min(ceil(centroids(:,1)), size(binaryMask,2));
centroids(:,2) = min(ceil(centroids(:,2)), size(binaryMask,1));
linearCentroids = sub2ind(size(binaryMask), centroids(:,1), centroids(:,2));

binaryMask =bwlabel(binaryMask);
objectCorrespondence = binaryMask(linearCentroids);
validCentroids = objectCorrespondence > 0;
props = regionprops(binaryMask, intensityImage, 'PixelValues');
processedValues = cellfun(myfun, {props.PixelValues});
measurements = zeros(length(linearCentroids), 2);
measurements(:,1) = objectCorrespondence;
measurements(validCentroids,2) = processedValues(objectCorrespondence(validCentroids));
measurements(~validCentroids,2) = -2;
end