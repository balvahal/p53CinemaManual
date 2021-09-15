function [ database ] = createDatabaseFile_subfolders(rawDataPath, outputFilePath)
dirCon_subfolders = dir(rawDataPath);
dirFlags = [dirCon_subfolders.isdir];
dirCon_subfolders = {dirCon_subfolders(dirFlags).name};

dirCon_subfolders = dirCon_subfolders(~ismember(dirCon_subfolders, {'.', '..'}));

fileDatabase = {};

for i=1:length(dirCon_subfolders)
    dirCon_files = dir(fullfile(rawDataPath, dirCon_subfolders{i}));
    dirCon_files = {dirCon_files(:).name};
    [validFiles, dirDict_files] = getTokenDictionary(dirCon_files, '(.+)_w\d([\w-]+).*_s(\d+)_t(\d+).*\.'); % For metamorph
    dirCon_files = dirCon_files(validFiles);
    filenames = fullfile(dirCon_subfolders{i}, dirCon_files);
    
    temp_database = horzcat(filenames', dirDict_files);
    fileDatabase = vertcat(fileDatabase, temp_database);
end

database = cell2table(fileDatabase, 'VariableNames', {'filename', 'group_label', 'channel_name', 'position_number', 'timepoint'});

writetable(database, outputFilePath, 'Delimiter', '\t');
end