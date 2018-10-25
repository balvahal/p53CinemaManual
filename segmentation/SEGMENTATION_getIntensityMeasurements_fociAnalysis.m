function output = SEGMENTATION_getIntensityMeasurements_fociAnalysis(database, rawDataPath, segmentDataPath, measurementChannel, segmentationChannel)
files = find(strcmp(database.channel_name, segmentationChannel));
uniqueGroups = unique(database.group_label);
[~, group_number] = ismember(database.group_label, uniqueGroups);
database.group_number = group_number;
output = zeros(length(unique(database.position_number)) * length(unique(database.timepoint)) * 200, 16);
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

        numObjects = bwconncomp(Nuclei);
        numObjects = numObjects.NumObjects;
        subsetIndex = counter:(counter + numObjects - 1);
        counter = counter + numObjects;
        
        currentFilename = getDatabaseFile2(database, currentGroupLabel, measurementChannel, currentPositionNumber, currentTimepoint);
        if(~isempty(currentFilename))
            IM = double(imread(fullfile(rawDataPath, currentFilename)));
            IM = imbackground(IM, 4, 50);
            IM(Nuclei == 0) = 0;
            LocalMaxima = double(imregionalmax(IM));
            measurements_nuclei = regionprops(Nuclei, IM, 'PixelValues', 'Area', 'Solidity', 'BoundingBox', 'Image');
            %                 for c=1:length(measurements_nuclei)
            %                     subsetIndex = {round(measurements_nuclei(c).BoundingBox(1):(measurements_nuclei(c).BoundingBox(1)+measurements_nuclei(c).BoundingBox(3)-1)), round(measurements_nuclei(c).BoundingBox(2):(measurements_nuclei(c).BoundingBox(2)+measurements_nuclei(c).BoundingBox(4)-1))};
            %                     cellImage = IM(subsetIndex{2}, subsetIndex{1}) .* measurements_nuclei(c).Image;
            %                 end
            measurements_localMaxima = regionprops(Nuclei, IM .* LocalMaxima, 'PixelValues');
            fociNumber = cellfun(@(x) sum(x > 0), {measurements_localMaxima.PixelValues});
            measurements_localMaxima = regionprops(Nuclei, IM .* imdilate(LocalMaxima, strel('disk', 2)), 'PixelValues');
            fociIntegratedIntensity = cellfun(@(x) sum(x), {measurements_localMaxima.PixelValues});
            NucleiQuantile_90 = cellfun(@(x) quantile(x, 0.9), {measurements_nuclei.PixelValues});
            NucleiQuantile_10 = cellfun(@(x) quantile(x, 0.1), {measurements_nuclei.PixelValues});
            NucleiIntegrated = cellfun(@(x) sum(x), {measurements_nuclei.PixelValues});
            NucleiVariance = cellfun(@(x) var(x), {measurements_nuclei.PixelValues});
            NucleiMean = cellfun(@(x) mean(x), {measurements_nuclei.PixelValues});
            NucleiQuantileAverage_90 = cellfun(@(x) mean(x(x > quantile(x, 0.9))), {measurements_nuclei.PixelValues});
            NucleiQuantileAverage_05_09 = cellfun(@(x) mean(x(x < quantile(x, 0.9) & x > quantile(x, 0.05))), {measurements_nuclei.PixelValues});
            
            output(subsetIndex,8) = fociNumber;
            output(subsetIndex,9) = fociIntegratedIntensity;
            output(subsetIndex,10) = NucleiQuantile_90;
            output(subsetIndex,11) = NucleiQuantile_10;
            output(subsetIndex,12) = NucleiIntegrated;
            output(subsetIndex,13) = NucleiVariance;
            output(subsetIndex,14) = NucleiMean;
            output(subsetIndex,15) = NucleiQuantileAverage_90;
            output(subsetIndex,16) = NucleiQuantileAverage_05_09;
        else
            output(subsetIndex,8:14) = -1;
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
output = array2table(output, 'VariableNames', horzcat({'group_number', 'position_number', 'timepoint','Area', 'Solidity', 'centroid_col', 'centroid_row'}, strcat({'ObjectNumber_Foci_', 'IntegratedIntensity_Foci_', 'QuantileIntensity_90_Nuclei_', 'QuantileIntensity_10_Nuclei_', 'IntegratedIntensity_Nuclei_', 'VarianceIntensity_Nuclei_', 'MeanIntensity_Nuclei_', 'QuantileIntensityAverage_90_Nuclei_', 'QuantileIntensityAverage_05_90_Nuclei_'}, measurementChannel)));
output.group_label = uniqueGroups(output.group_number);
fprintf('%d\n', progress);
end