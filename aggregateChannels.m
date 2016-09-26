function [] = aggregateChannels(database, rawdatapath, channels)

validFiles = find(ismember(database.channel_name, channels));

file_info = imfinfo(fullfile(rawdatapath, database.filename{validFiles(1)}));

uniqueGroups = unique(database.group_label);
[~, group_number] = ismember(database.group_label, uniqueGroups);
for g=1:length(group_number);
    unique_positions = unique(database.position_number(group_number == g));
    for s=1:length(unique_positions)
        currentPosition = unique_positions(s);
        unique_timepoints = unique(database.timepoint(group_number == g & database.position_number == currentPosition));
        for t=1:length(unique_timepoints)
            current_timepoint = unique_timepoints(t);
            numChannels = length(channels);
            FinalImage = zeros(file_info.Height, file_info.Width);
            for i=1:length(channels)
                currentFilename = getDatabaseFile2(database, uniqueGroups{g}, channels{i}, currentPosition, current_timepoint);
                if(exist(fullfile(rawdatapath, currentFilename), 'file'))
                    IM = imread(fullfile(rawdatapath, currentFilename));
                    IM = imnormalize_quantile(IM, 0.99) / numChannels;
                    FinalImage = FinalImage + IM;
                end
            end
            FinalImage = uint16(FinalImage * (2^16-1));
            outputFilename = regexprep(currentFilename, 'w\d.*_s', 'w0MergedChannels_s');
            imwrite(FinalImage, fullfile(rawdatapath, outputFilename), 'TIF', 'Compression', 'none');
        end
    end
end