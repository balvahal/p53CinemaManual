function measurements = regionprops_withKnownCentroids(binaryMask, intensityImage, centroids, measurementType)
%Centroids is in row,col (y,x) format    
centroids(:,1) = min(ceil(centroids(:,1)), size(binaryMask,2));
centroids(:,2) = min(ceil(centroids(:,2)), size(binaryMask,1));
linearCentroids = sub2ind(size(binaryMask), centroids(:,1), centroids(:,2));

binaryMask =bwlabel(binaryMask);
objectCorrespondence = binaryMask(linearCentroids);
validCentroids = objectCorrespondence > 0;
if(~isempty(intensityImage))
    props = regionprops(binaryMask, intensityImage, measurementType);
else
    props = regionprops(binaryMask, measurementType);
end
measurements = zeros(length(linearCentroids), 2);
measurements(:,1) = objectCorrespondence;
measurements(validCentroids,2) = [props(objectCorrespondence(validCentroids)).(measurementType)];
measurements(~validCentroids,2) = -2;
end