function getBrightfieldNucleiCentroids(IM)
    IM = imnormalize(IM);
    ContrastImage = adapthisteq(IM);
    EntropyImage = imnormalize(entropyfilt(IM));
    
    thresholdedImage = im2bw(EntropyImage, graythresh(EntropyImage));
    thresholdedImage = imerode(thresholdedImage, strel('disk', 6));
    
    EntropyImageHigh = imnormalize(stdfilt(IM, getnhood(strel('disk', 7))));
    EntropyImageHigh = (imregionalmax(-EntropyImageHigh) | imregionalmax(EntropyImageHigh)) & thresholdedImage;
    EntropyImageHigh = imdilate(EntropyImageHigh, strel('disk', 2));
    
    EntropyImage2 = imnormalize(entropyfilt(IM, getnhood(strel('disk', 7))));
    EntropyImage2 = (imregionalmax(EntropyImage2)) & thresholdedImage;
    EntropyImage2 = imdilate(EntropyImage2, strel('disk', 2));

    
    %EntropyImageHigh = im2bw(EntropyImageHigh, graythresh(EntropyImageHigh));
    imshow(imoverlay(ContrastImage, EntropyImageHigh & EntropyImage2, [0.3, 1, 0.3]));
    
    EntropyImageLow = imnormalize(entropyfilt(IM, getnhood(strel('disk', 5))));
    
    ContrastImage = adapthisteq(IM);
    darkImage = ContrastImage <= quantile(ContrastImage(:), 0.1);
    EntropyMaxima = imregionalmax(EntropyImageHigh) & thresholdedImage;
    EntropyMinima = imregionalmax(EntropyImageLow) & thresholdedImage;
    overlay1 = imoverlay(ContrastImage, EntropyMaxima, [.3 1 .3]);
    overlay2 = imoverlay(overlay1, EntropyMinima, [1, 0.3 0.3]);
    imshow(overlay2);
    
    edgeImage = edge(ContrastImage);
    edgeImage = imfill(bwmorph(edgeImage, 'bridge', getnhood(strel('square', 21))), 'holes');
    imshow(edgeImage);
    darkImage = ContrastImage <= quantile(ContrastImage(:), 0.1);
    imagesc(edgeImage + (edgeImage & darkImage));
    imshow(imoverlay(ContrastImage, edgeImage & darkImage & thresholdedImage, [0.3, 1, 0.3]));
    
    potentialNucleoli = edgeImage & darkImage & thresholdedImage;
    potentialNucleoli = bwlabel(potentialNucleoli);
    props = regionprops(potentialNucleoli, 'Area');
    potentialNucleoli = ismember(potentialNucleoli, find(ismember([props.Area], 5:1000)));
    overlay1 = imoverlay(ContrastImage, potentialNucleoli, [0.3, 1, 0.3]);
    overlay2 = imshow(imoverlay(overlay1, bwperim(thresholdedImage), [1, 0.3, 0.3]));
    overlay1 = imoverlay(ContrastImage, potentialNucleoli & ~(imdilate(bwperim(thresholdedImage), strel('disk', 3))), [0.3, 1, 0.3]);
    
    borderIntersection = potentialNucleoli + bwperim(thresholdedImage) == 2;
    borderIntersection = find(borderIntersection);
    cleanBorders = imfill(bwperim(imdilate(potentialNucleoli, strel('disk', 1))), borderIntersection);
    potentialNucleoli = (potentialNucleoli & ~cleanBorders);
    overlay1 = imoverlay(ContrastImage, potentialNucleoli, [0.3, 1, 0.3]);

    
end