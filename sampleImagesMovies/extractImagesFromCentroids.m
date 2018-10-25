function [] = extractImagesFromCentroids(database, rawdatapath, annotation, timepoint, centroids_row, centroids_col, channel, dimensions, outputFile)
% dimensions is a [height, width] vector
% The row col relationship is shifted in
% getDatasetTraces_fillLineageInformation. I will correct this, and will
% have to modify this code to re-adjust.
uniqueGroups = unique(annotation(:,1));
subImages = zeros(dimensions(1), dimensions(2), size(annotation,1));
progress = 0;
counter = 0;
for i=1:length(uniqueGroups)
    currentGroup = uniqueGroups{i};
    uniquePositions = unique([annotation{strcmp(annotation(:,1),currentGroup),2}]);
    for j = 1:length(uniquePositions)
        currentPosition = uniquePositions(j);
        uniqueTimepoints = unique(timepoint(strcmp(annotation(:,1),currentGroup)' & [annotation{:,2}] == currentPosition));
        for t=1:length(uniqueTimepoints)
            currentTimepoint = uniqueTimepoints(t);
            currentImageFilename = getDatabaseFile2(database, currentGroup, channel, currentPosition, currentTimepoint);
            if(isempty(currentImageFilename))
                fprintf('Cannot find image for group %s, channel %s, position %d, timepoint %d\n', currentGroup, channel, currentPosition, currentTimepoint);
                continue;
            end
            IM = imread(fullfile(rawdatapath, currentImageFilename));
            %IM = imbackground(IM, 100, 10);
            validCentroids = find(strcmp(annotation(:,1),currentGroup) & ([annotation{:,2}] == currentPosition)' & timepoint == currentTimepoint);
            for c = 1:length(validCentroids)
                counter = counter + 1;
                if(counter / size(annotation,1) > progress + 0.1)
                    fprintf('%d ', floor(progress * 10));
                    progress = progress + 0.1;
                end
                currentCentroids = [centroids_row(validCentroids(c)), centroids_col(validCentroids(c))];
                subsetIndex = [min(max(currentCentroids(1)-dimensions(1)/2,1), size(IM,1)-dimensions(1)), min(max(currentCentroids(2)-dimensions(2)/2,1), size(IM,2)-dimensions(2))];
                subImage = IM(subsetIndex(2):(subsetIndex(2) + dimensions(2)-1), subsetIndex(1):(subsetIndex(1) + dimensions(1)-1));
                subImages(:,:,validCentroids(c)) = subImage(:,:);
                %imwrite(uint16(subImage), outputFile, 'WriteMode', 'append', 'Compression', 'none');
            end
        end
    end
end
for i=1:size(annotation,1)
    subImage = subImages(:,:,i);
    imwrite(uint16(subImage), outputFile, 'WriteMode', 'append', 'Compression', 'none');
end
fprintf('%d\n', 100);
end