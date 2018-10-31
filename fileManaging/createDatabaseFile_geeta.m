function [ database ] = createDatabaseFile_geeta(rawDataPath, outputFilePath)
dirCon_subfolders = dir(rawDataPath);
dirCon_subfolders = {dirCon_subfolders(:).name};

[validFiles, dirDict_subfolders] = getTokenDictionary(dirCon_subfolders, 'Well (\w)(\d+)'); % For geeta, Well folders
dirCon_subfolders = dirCon_subfolders(validFiles);

fileDatabase = {};

for i=1:length(dirCon_subfolders)
    dirCon_files = dir(fullfile(rawDataPath, dirCon_subfolders{i}));
    dirCon_files = {dirCon_files(:).name};
    [validFiles, dirDict_files] = getTokenDictionary(dirCon_files, '(.+) - n(\d+)'); % For geeta, Well folders
    dirCon_files = dirCon_files(validFiles);
    filenames = fullfile(dirCon_subfolders{i}, dirCon_files);
    
    row_id = repmat(dirDict_subfolders(i,1), length(dirCon_files), 1);
    col_id = repmat(dirDict_subfolders(i,2), length(dirCon_files), 1);
    
    temp_database = horzcat(filenames', dirDict_files, row_id, col_id);
    fileDatabase = vertcat(fileDatabase, temp_database);
end

well_id = strcat(fileDatabase(:,4), fileDatabase(:,5));
unique_well_ids = unique(well_id);
[~, position_number] = ismember(well_id, unique_well_ids);

database = cell2table(fileDatabase, 'VariableNames', {'filename', 'channel_name', 'timepoint', 'row_id', 'column_id'});
database.position_number = position_number;
database.group_label = repmat({'Exp'}, size(database,1),1);

writetable(database, outputFilePath, 'Delimiter', '\t');
end