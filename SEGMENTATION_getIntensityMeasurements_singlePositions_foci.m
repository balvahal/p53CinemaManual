function [] = SEGMENTATION_getIntensityMeasurements_singlePositions_foci(database, rawDataPath, segmentDataPath, outputPath, measurementChannels, fociChannels, segmentationChannel)
uniqueGroups = unique(database.group_label);
for i=1:length(uniqueGroups)
    subDatabase = database(strcmp(database.group_label, uniqueGroups{i}),:);
    uniquePositions = unique(subDatabase.position_number);
    for s=1:length(uniquePositions)
        fprintf('Measuring position %d\n', uniquePositions(s));
        measurements = SEGMENTATION_getIntensityMeasurements_allPositions(subDatabase(subDatabase.position_number == uniquePositions(s),:), rawDataPath, segmentDataPath, measurementChannels, segmentationChannel);
        for w=1:length(fociChannels)
            measurements_temp = SEGMENTATION_getIntensityMeasurements_fociAnalysis(subDatabase(subDatabase.position_number == uniquePositions(s),:), rawDataPath, segmentDataPath, fociChannels{w}, segmentationChannel);
            measurements = horzcat(measurements, measurements_temp(:,8:(end-1)));
        end
        writetable(measurements, fullfile(outputPath, sprintf('%s_s%d.txt', uniqueGroups{i}, uniquePositions(s))), 'Delimiter', '\t');
    end
end
end