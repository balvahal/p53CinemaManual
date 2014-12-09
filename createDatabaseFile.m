function [ database ] = createDatabaseFile(rawDataPath, outputFilePath)
dirCon = dir(rawDataPath);
dirCon = {dirCon(:).name};
% Commented regular expression for Elements file naming scheme
%[validFiles, dirDict] = getTokenDictionary(dirCon, '(.*)?t(\d+)xy(\d+)c(\d)\.tif');
%[validFiles, dirDict] = getTokenDictionary(dirCon, '(.*)?xy(\d+)c(\d)t(\d+)\.tif');
[validFiles, dirDict] = getTokenDictionary(dirCon, '(\w+)_w\d(\w+).*_s(\d+)_t(\d+).*\.');
%[validFiles, dirDict] = getTokenDictionary(dirCon, '(\w+)_s(\d+)_w\d(\w+).*_t(\d+).*\.');
%[validFiles, dirDict] = getTokenDictionary(dirCon, 'g(\d+)_(.*)_s(\d+)_.*tile(\d).*_w\d_(.*)_t(\d+).*\.');
%[validFiles, dirDict] = getTokenDictionary(dirCon, 'g(\d+)_(.*)_s(\d+)_w\d_(.*)_t(\d+).*\.');
dirCon = dirCon(validFiles);
dirDict = horzcat(dirCon', dirDict);
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_label', 'position_number','channel_name', 'timepoint'});
database = cell2table(dirDict, 'VariableNames', {'filename', 'group_label', 'channel_name', 'position_number', 'timepoint'});
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_label', 'position_number', 'channel_name', 'timepoint'});
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_number', 'group_label', 'position_number', 'tile_number', 'channel_name', 'timepoint'});
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_number', 'group_label', 'position_number', 'channel_name', 'timepoint'});
writetable(database, outputFilePath, 'Delimiter', '\t');
end