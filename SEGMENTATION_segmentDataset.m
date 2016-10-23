%% cellularGPS_segmentDataset
% Find centroids for cells based upon a nuclear marker or signal.
%
% [] = cellularGPS_segmentDataset(database, rawDataPath, segmentDataPath, channel)
%
%%% Input
% * database: database table of SuperMDA format.
% * rawDataPath: path to the folder of images.
% * segmentDataPath: output folder for segmented images
% * channel: a string. The name of the channel used for segmentation.
%
%%% Output:
% For each position from the dataset a table of centroid information is
% created. For each image of a particular _channel_, a segmentation file is
% created.
%
%%% Detailed Description
% There is no detailed description.
%
%%% Other Notes
%
function [] = SEGMENTATION_segmentDataset(database, rawDataPath, segmentDataPath, channel)
database = database(strcmp(database.channel_name, channel),:);
uniqueGroups = unique(database.group_label);
for i=1:length(uniqueGroups);
    selectedGroup = uniqueGroups{i};
    uniquePositions = unique(database.position_number(strcmp(database.group_label, selectedGroup)));
    for j=1:length(uniquePositions)
        selectedPosition = uniquePositions(j);
        fprintf('Analyzing position %d\n', selectedPosition);
        files = find(strcmp(database.group_label, selectedGroup) & database.position_number == selectedPosition);
        centroidTable = repmat({zeros(2^8,3)},length(files),1);
        centroidNumber = zeros(length(files),1);
        parfor k=1:length(files)
            timepoint = database.timepoint(files(k));
            outputFilename = regexprep(database.filename(files(k)), '\.', '_segment.');
            
            if(~exist(fullfile(segmentDataPath,outputFilename{1}), 'file'))
                try
                    IM = imread(fullfile(rawDataPath, database.filename{files(k)}));
                    IM = medfilt2(IM, [2,2]);
                    IM = imbackground(IM, 5, 60);
                    [Objects, Centroids] = SEGMENTATION_identifyPrimaryObjectsGeneral(IM);
                    imwrite(Objects, fullfile(segmentDataPath,outputFilename{1}), 'tif');
                catch e
                    fprintf('%s\t%s\n', outputFilename{1}, e.message);
                end
            else
                try
                    info = imfinfo(fullfile(segmentDataPath,outputFilename{1}));
                catch e
                    fprintf('%s\t%s\n', outputFilename{1}, e.message);
                end 
            end
        end
%         allCentroids = zeros(sum(centroidNumber),3);
%         numberOfCentroidsCounter = 1;
%         for k=1:length(files)
%             allCentroids(numberOfCentroidsCounter:(numberOfCentroidsCounter+centroidNumber(k)-1),:) = centroidTable{k}(1:centroidNumber(k),:);
%             numberOfCentroidsCounter = numberOfCentroidsCounter + centroidNumber(k);
%         end
%         allCentroids = array2table(allCentroids, 'VariableNames', {'centroid_col', 'centroid_row', 'timepoint'});
%         tableFilename = sprintf('%s_s%d_w%d%s_centroidsTable.txt', selectedGroup, selectedPosition, database.channel_number(k), channel);
%         writetable(allCentroids, fullfile(segmentDataPath,'tables',tableFilename), 'Delimiter', '\t');
    end
end
end
