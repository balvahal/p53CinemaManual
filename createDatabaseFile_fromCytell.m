function [ database ] = createDatabaseFile_fromCytell(experimentPath, experimentPrefix, outputFilePath)
dirCon = dir(experimentPath);
dirCon = {dirCon([dirCon(:).isdir]).name};
folderNames = dirCon(~cellfun(@isempty, regexp(dirCon, experimentPrefix)));
combinedDictionary = [];
for i=1:length(folderNames)
    dirCon = dir(fullfile(experimentPath, folderNames{i}));
    dirCon = {dirCon(:).name};
    [validFiles, dirDict] = getTokenDictionary(dirCon, '(\w) - (\d+)\(fld (\d+)[ wv ]*(\w*)'); % For metamorph scan
    dirDict(strcmp(dirDict(:,4),''),4) = {'DAPI'};
    dirCon = dirCon(validFiles);
    dirDict = horzcat(dirCon', dirDict);
    dirDict = horzcat(repmat(folderNames(i),size(dirDict,1),1),dirDict);
    combinedDictionary = vertcat(combinedDictionary, dirDict);
end

database = cell2table(combinedDictionary, 'VariableNames', {'subfolder', 'filename', 'column', 'row', 'field', 'channel_name'}); % For metamorph scan
writetable(database, outputFilePath, 'Delimiter', '\t');
database = readtable(outputFilePath, 'Delimiter', '\t');

uniqueRows = unique(database.row);
uniqueColumns = unique(database.column);
uniqueFields = unique(database.field);

[~, row_number] = ismember(database.row, uniqueRows);
[~, col_number] = ismember(database.column, uniqueColumns);
[~, field_number] = ismember(database.field, uniqueFields);

database.row_number = row_number;
database.col_number = col_number;
database.field_number = field_number;

database.position_number = (database.row_number - 1) * length(uniqueColumns) * length(uniqueFields) + (database.col_number - 1) *  length(uniqueFields) + database.field_number;
database.group_label = database.subfolder;
database.filename = fullfile(database.subfolder, database.filename);
database.timepoint = repmat(1, size(database,1), 1);
writetable(database, outputFilePath, 'Delimiter', '\t');

end