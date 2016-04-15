function output = SEGMENTATION_getIntensityMeasurements(database, rawDataPath, segmentDataPath, measurementChannels, segmentationChannel)
files = find(strcmp(database.channel_name, segmentationChannel));
uniqueGroups = unique(database.group_label);
[~, group_number] = ismember(database.group_label, uniqueGroups);
database.group_number = group_number;
output = zeros(length(unique(database.position_number)) * length(unique(database.timepoint)) * 200, 5 + length(measurementChannels));
counter = 1;
progress = 0;
for i=1:length(files)
    if(i/length(files) * 100 > progress)
        fprintf('%d ', progress);
        progress = progress + 10;
    end
    
    currentGroupLabel = database.group_label{files(i)};
    currentGroupNumber = database.group_number(files(i));
    currentPositionNumber = database.position_number(files(i));
    currentTimepoint = database.timepoint(files(i));
    
    segmentFilename = regexprep(database.filename{files(i)}, '_w\d.*?_', '_');
    if(~exist(fullfile(segmentDataPath, segmentFilename), 'file'))
        continue;
    end
    try
        Objects = imread(fullfile(segmentDataPath, segmentFilename));
        numObjects = bwconncomp(Objects);
        numObjects = numObjects.NumObjects;
        subsetIndex = counter:(counter + numObjects - 1);
        counter = counter + numObjects;
        
        for w=1:length(measurementChannels)
            currentFilename = getDatabaseFile2(database, currentGroupLabel, measurementChannels{w}, currentPositionNumber, currentTimepoint);
            if(~isempty(currentFilename))
                IM = imread(fullfile(rawDataPath, currentFilename));
                IM = imbackground(IM, 4, 50);
                measurements = regionprops(logical(Objects), IM, 'MeanIntensity');
                output(subsetIndex,5+w) = [measurements.MeanIntensity];
            else
                output(subsetIndex,5+w) = -1;
            end
        end
        measurementsArea = regionprops(logical(Objects), 'Area', 'Solidity');
        output(subsetIndex,4) = [measurementsArea.Area];
        output(subsetIndex,5) = [measurementsArea.Solidity];
        output(subsetIndex,1:3) = repmat([currentGroupNumber, currentPositionNumber, currentTimepoint], length(measurements), 1);
    catch err
        fprintf('%s\t%s\n', segmentFilename, err.message)
    end
end
output = output(1:(counter-1),:);
output = array2table(output, 'VariableNames', horzcat({'group_number', 'position_number', 'timepoint','Area', 'Solidity'}, strcat('MeanIntensity_', measurementChannels)));
output.group_label = uniqueGroups(output.group_number);
fprintf('%d\n', progress);
end