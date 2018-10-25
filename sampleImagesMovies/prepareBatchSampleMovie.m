function [] = prepareBatchSampleMovie(database, rawDataPath, traces, annotation, channel, tracking_path, dimensions, outputPath)
uniqueGroups = unique(annotation(:,1));
for g=1:length(uniqueGroups)
    currentGroup = uniqueGroups{g};
    subAnnotation = annotation(strcmp(annotation(:,1), currentGroup),:);
    if(~isempty(traces))
        subTraces = traces(strcmp(annotation(:,1), currentGroup),:);
    else
        subTraces = [];
    end
    uniquePositions = unique([subAnnotation{:,2}]);
    for s=1:length(uniquePositions)
        tracking_file = sprintf('%s_s%d_tracking.mat', currentGroup, uniquePositions(s));
        load(fullfile(tracking_path, tracking_file));
        cellIndexes = [subAnnotation{[subAnnotation{:,2}] == uniquePositions(s),3}];
        fprintf('%s\n', tracking_file);
        validImages = strcmp(database.group_label, selectedGroup) & database.position_number == selectedPosition & strcmp(database.channel_name, channel);
        batchSampleMovies(database(validImages,:), rawDataPath, centroidsTracks, cellIndexes, subTraces, dimensions, outputPath);
    end
end
end