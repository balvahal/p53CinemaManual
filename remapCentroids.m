function remappedCentroids = centroid2localmax(centroids, imageSequence)
    for i=1:size(images,3)
        IM = imread(imageSequence{i});
        currentCentroids = centroids(centroids(:,2) == i, :);
        BlurredImage = imfilter(IM, fspecial('gaussian', 15, 4), 'replicate');
        LocalMaxima = imregionalmax(BlurredImage);
        [i,j] = ind2sub(size(IM), find(LocalMaxima));
        
    end
end