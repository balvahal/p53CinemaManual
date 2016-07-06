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

unique_rows = unique(database.row);
unique_columns = unique(database.column);
[~, row_number] = ismember(database.row, unique_rows);
[~, col_number] = ismember(database.column, unique_columns);
database.position_number = (row_number - 1) * length(unique_rows) + col_number;

writetable(database, outputFilePath, 'Delimiter', '\t');
end