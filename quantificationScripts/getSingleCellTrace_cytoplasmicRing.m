function singleCellTracks = getSingleCellTrace_cytoplasmicRing(rawdatapath, segmentationpath, database, group, position, measurementChannel, segmentationChannel, centroids)
trackedCells = centroids.getTrackedCellIds;
numTracks = length(trackedCells);
numTimepoints = length(centroids.singleCells);

singleCellTracks = -ones(numTracks, numTimepoints);
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
    end
    
    if(~isempty(segmentationChannel))
        segmentFile = getDatabaseFile2(database, group, segmentationChannel, position, i);
        if(isempty(segmentFile))
            continue;
        end

        segmentFile = regexprep(segmentFile, '_w\d_*.*?_([st])', '_$1');
        
        if(~exist(fullfile(segmentationpath, segmentFile), 'file'))
            continue;
        end
        Nuclei = double(imerode(imread(fullfile(segmentationpath, segmentFile)), strel('disk', 1)));
        Nuclei = bwlabel(Nuclei);
    end
    
    % Get current centroids
    [currentCentroids, validCells] = centroids.getCentroids(i);
    [~, validCells] = ismember(validCells, trackedCells);
    
    if(isempty(validCells))
        continue;
    end
    
    % Read image and object files
    IntensityImage = double(imread(fullfile(rawdatapath, measurementFile)));
    IntensityImage = medfilt2(IntensityImage, [2,2]);
    IntensityImage = imbackground(IntensityImage, 10, 100);

    scalingFactor = 1;
    currentCentroids(:,1) = round(min(currentCentroids(:,1) * scalingFactor, size(Nuclei,1)));
    currentCentroids(:,2) = round(min(currentCentroids(:,2) * scalingFactor, size(Nuclei,2)));
    
    for c =1:length(validCells)
        currentObject = Nuclei(currentCentroids(c,1), currentCentroids(c,2));
        if(currentObject > 0)
            ObjectsTemp = Nuclei == currentObject;
            ObjectsDilated = imdilate(ObjectsTemp, strel('disk', 4));
            ObjectsDilated = ObjectsDilated & ~imdilate(ObjectsTemp, strel('disk', 1));
            pixelValues = IntensityImage(ObjectsDilated);
            ringValue = mean(pixelValues);
            pixelValues = IntensityImage(Nuclei == currentObject);
            nucleiValue = mean(pixelValues);
            singleCellTracks(validCells(c), i) = ringValue;
        end
    end
    
%     nucleiMeasurements = regionprops_withKnownCentroids(Nuclei, IntensityImage, currentCentroids, 'MeanIntensity');
%     singleCellTracks(validCells, i) = nucleiMeasurements(:,2);
%     singleCellTracks(singleCellTracks(:,i) == -2,i) = 0;
%     
%     cytoplasmMeasurements = regionprops(Cytoplasm, IntensityImage, 'MeanIntensity');
%     
%     singleCellTracks(validCells, i) = singleCellTracks(validCells, i) ./ [cytoplasmMeasurements.MeanIntensity];
    
    % Repeated values (divisions, for instance)
%     currentCentroids = sub2ind(size(Nuclei), currentCentroids(:,1), currentCentroids(:,2));
%     if(length(currentCentroids) > 1)
%         centroidFrequency = tabulate(currentCentroids);
%         repeatedValues = centroidFrequency(centroidFrequency(:,2) > 1,1);
%         for j=1:length(repeatedValues)
%             repeatedIndexes = validCells(currentCentroids == repeatedValues(j));
%             singleCellTracks(repeatedIndexes,i) = max(singleCellTracks(repeatedIndexes,i));
%         end
%     end
end
fprintf('\n');
end