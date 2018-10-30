function imageStrip = prepareBatchSampleMovie_RGB(database, rawDataPath, traces, annotation, channel, tracking_path, dimensions, outputPath, stepSize, colorcode, colorTraces, ylimit, outputMode)
% Map colors index to traces
if(isempty(traces))
    fprintf('You need to specify the set of traces for this to work!\n');
    return;
end
if(isempty(colorTraces))
    colorTraces = traces;
    ylimit = [min(traces(:)), max(traces(:))];
end
colorTraces = floor((colorTraces - min(ylimit))/max(ylimit) * (size(colorcode,1)-1)) + 1;
colorTraces(colorTraces < 1) = 1;
colorTraces(colorTraces > size(colorcode,1)) = size(colorcode,1);
        
timepoints = unique(database.timepoint);
timepoints = 1:stepSize:max(timepoints);
database = database(ismember(database.timepoint, timepoints),:);
traces = traces(:,timepoints);
colorTraces = colorTraces(:,timepoints);

if(strcmp(outputMode, 'stack'))
    imageStrip = [];
else
    imageStrip = zeros(dimensions(1)*size(annotation,1), dimensions(2)*length(timepoints), 3);
end

f = figure; set(f, 'Color', 'w');
a1 = gca;

uniqueGroups = unique(annotation(:,1));
for g=1:length(uniqueGroups)
    currentGroup = uniqueGroups{g};
    
    uniquePositions = unique([annotation{strcmp(annotation(:,1), currentGroup),2}]);
    for s=1:length(uniquePositions)
        tracking_file = sprintf('%s_s%d_tracking.mat', currentGroup, uniquePositions(s));
        load(fullfile(tracking_path, tracking_file));
        
        validTraces = find(strcmp(annotation(:,1), currentGroup) & [annotation{:,2}]' == uniquePositions(s));
        cellIndexes = [annotation{validTraces,3}];
        subTraces = traces(validTraces,:);
        subColorTraces = colorTraces(validTraces,:);
        
        fprintf('%s\n', tracking_file);
        validImages = strcmp(database.group_label, selectedGroup) & database.position_number == selectedPosition & strcmp(database.channel_name, channel);
        singleStrip = batchSampleMovies_RGB(database(validImages,:), rawDataPath, centroidsTracks, cellIndexes, subTraces, dimensions, outputPath, colorcode, subColorTraces, outputMode);
        
        if(~strcmp(outputMode, 'stack'))
            for i=1:length(singleStrip)
                currentCell = validTraces(i);
                imageStrip((dimensions(1)*(currentCell-1) + 1):(dimensions(1)*(currentCell-1) + dimensions(1)),:,:) = singleStrip{i};
            end
            image(imageStrip, 'parent', a1); drawnow;
        end
    end
end
end