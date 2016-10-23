function [ database ] = createDatabaseFile_fromInCell(rawDataPath, outputFilePath)
dirCon = dir(rawDataPath);
dirCon = {dirCon(:).name};
% Commented regular expression for Elements file naming scheme
[validFiles, dirDict] = getTokenDictionary(dirCon, '(\w) - (\d+)\(fld (\d+) wv \w+ - (\w+)- time (\d+)'); % For inCell
dirCon = dirCon(validFiles);
dirDict = horzcat(dirCon', dirDict);

database = cell2table(dirDict, 'VariableNames', {'filename', 'row', 'column', 'field', 'channel_name', 'timepoint'}); % For inCell
database.group_label = repmat({'Exp'}, size(database, 1), 1);

writetable(database, outputFilePath, 'Delimiter', '\t');
database = readtable(outputFilePath, 'Delimiter', '\t');

uniqueRows = unique(database.row);
uniqueColumns = unique(database.column);
uniqueFields = unique(database.field);

[~, row_number] = ismember(database.row, uniqueRows);
[~, col_number] = ismember(database.row, uniqueColumns);
[~, field_number] = ismember(database.row, uniqueFields);

database.row_number = row_number;
database.col_number = col_number;
database.field_number = field_number;

database.position_number = (database.row_number - 1) * length(uniqueColumns) * length(uniqueFields) + (database.col_number - 1) *  length(uniqueFields) + database.field_number;

end