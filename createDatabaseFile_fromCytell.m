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
end