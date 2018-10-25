function output = SEGMENTATION_getIntensityMeasurements_MeanIntegrated(database, rawDataPath, segmentDataPath, measurementChannels, segmentationChannel)
files = find(strcmp(database.channel_name, segmentationChannel));
uniqueGroups = unique(database.group_label);
[~, group_number] = ismember(database.group_label, uniqueGroups);
database.group_number = group_number;
output = zeros(length(unique(database.position_number)) * length(unique(database.timepoint)) * 200, 7 + 3 * length(measurementChannels));
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
    
    segmentFilename = regexprep(database.filename{files(i)}, '\.', '_segment.');

    if(~exist(fullfile(segmentDataPath, segmentFilename), 'file'))
        continue;
    end
    try
        Nuclei = double(imerode(imread(fullfile(segmentDataPath, segmentFilename)), strel('disk', 1)));
        Nuclei = bwlabel(Nuclei);
        Cytoplasm = imdilate(Nuclei, strel('disk', 3));
        Cytoplasm(Nuclei > 0) = 0;

        numObjects = bwconncomp(Nuclei);
        numObjects = numObjects.NumObjects;
        subsetIndex = counter:(counter + numObjects - 1);
        counter = counter + numObjects;
        
        for w=1:length(measurementChannels)
            currentFilename = getDatabaseFile2(database, currentGroupLabel, measurementChannels{w}, currentPositionNumber, currentTimepoint);
            if(~isempty(currentFilename))
                IM = imread(fullfile(rawDataPath, currentFilename));
                IM = imbackground(IM, 4, 50);
                measurements_nuclei = regionprops(Nuclei, IM, 'PixelValues');
                output(subsetIndex,7 + w) = cellfun(@mean, {measurements_nuclei.PixelValues});
                output(subsetIndex,7 + w + length(measurementChannels)) = cellfun(@sum, {measurements_nuclei.PixelValues});
                measurements_cytoplasm = regionprops(Cytoplasm, IM, 'PixelValues');
                output(subsetIndex,7 + w + 2*length(measurementChannels)) = cellfun(@mean, {measurements_cytoplasm.PixelValues});
            else
                output(subsetIndex,7+w) = -1;
                output(subsetIndex,7 + w + length(measurementChannels)) = -1;
                output(subsetIndex,7 + w + 2*length(measurementChannels)) = -1;
            end
        end
        measurementsArea = regionprops(logical(Nuclei), 'Area', 'Solidity', 'Centroid');
        output(subsetIndex,4) = [measurementsArea.Area];
        output(subsetIndex,5) = [measurementsArea.Solidity];
        output(subsetIndex,1:3) = repmat([currentGroupNumber, currentPositionNumber, currentTimepoint], length(measurementsArea), 1);
        output(subsetIndex,6:7) = reshape([measurementsArea.Centroid], 2, length(measurementsArea))';
    catch err
        fprintf('%s\t%s\n', segmentFilename, err.message)
    end
end
output = output(1:(counter-1),:);
output = array2table(output, 'VariableNames', horzcat({'group_number', 'position_number', 'timepoint','Area', 'Solidity', 'centroid_col', 'centroid_row'}, strcat('MeanIntensity_Nuclei_', measurementChannels), strcat('IntegratedIntensity_Nuclei_', measurementChannels), strcat('MeanIntensity_Cytoplasm_', measurementChannels)));
output.group_label = uniqueGroups(output.group_number);
fprintf('%d\n', progress);
end