function databaseFile = createDatabaseFile_fromMicromanager(rawdatapath, outputFile)
dirCon = dir(rawdatapath);
dirCon = {dirCon(:).name};
[validFolders, dirDict] = getTokenDictionary(dirCon, 'Pos(\d+)');
dirCon = dirCon(logical(validFolders));
databaseFile = table();
for i=1:length(dirCon)
    filenames = dir(fullfile(rawdatapath, dirCon{i}));
    filenames = {filenames(:).name};
    [validFiles, fileDict] = getTokenDictionary(filenames, 'img_(\d+)_(.*)_');
    fileDict = cell2table(fileDict);
    fileDict.Properties.VariableNames = {'timepoint', 'channel_name'};
    fileDict.filename = fullfile(dirCon{i}, filenames(validFiles))';
    fileDict.position_number = repmat(dirDict(i,1), size(fileDict,1), 1);
    databaseFile = vertcat(databaseFile, fileDict);
end
database.group_label = repmat(rawdatapath, size(databaseFile,1), 1);
writetable(databaseFile, outputFile, 'Delimiter', '\t');
end