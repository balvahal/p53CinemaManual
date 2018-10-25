function [ database ] = createDatabaseFile_forGiorgio(rawDataPath, outputFilePath)
dirCon = dir(rawDataPath);
dirCon = {dirCon(:).name};

% Commented regular expression for Elements file naming scheme
[validFiles, dirDict] = getTokenDictionary(dirCon, '(.+)-(\d+)-(\d+)001(\d+).tif'); % for Giorgio
 
dirCon = dirCon(validFiles);
dirDict = horzcat(dirCon', dirDict);

database = cell2table(dirDict, 'VariableNames', {'filename', 'well_id', 'field_number', 'timepoint', 'channel_name'}); % For Giorgio

database.channel_name = strcat('channel_', database.channel_name);
database.group_label = repmat({'Exp'}, size(database,1), 1);

writetable(database, outputFilePath, 'Delimiter', '\t');

database = readtable(outputFilePath, 'Delimiter', '\t');

unique_wells = unique(database.well_id);
maxField = max(database.field_number);
[~, well_id] = ismember(database.well_id, unique_wells);
database.position_number = database.field_number + (database.well_id - 1) * maxField_number;

writetable(database, outputFilePath, 'Delimiter', '\t');

end