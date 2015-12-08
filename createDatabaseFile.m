function [ database ] = createDatabaseFile(rawDataPath, outputFilePath)
dirCon = dir(rawDataPath);
dirCon = {dirCon(:).name};
% Commented regular expression for Elements file naming scheme
%[validFiles, dirDict] = getTokenDictionary(dirCon, '(.*)?c(\d)xy(\d+)t(\d+)'); %For NIS elements
%[validFiles, dirDict] = getTokenDictionary(dirCon, '(.*)?t(\d+)xy(\d+)c(\d)\.tif');
%[validFiles, dirDict] = getTokenDictionary(dirCon, '(.*)?xy(\d+)c(\d)t(\d+)\.tif');
[validFiles, dirDict] = getTokenDictionary(dirCon, '(.+)_w\d(\w+).*_s(\d+)_t(\d+).*\.'); % For metamorph
%[validFiles, dirDict] = getTokenDictionary(dirCon, '(.+)_w\d(\w+).*_s(\d+)_t(\d+)_z(\d+)\.'); % For metamorph with z
%[validFiles, dirDict] = getTokenDictionary(dirCon, '(.+)_w(\d)_s(\d+)_t\d+\.'); % For metamorph scan
%[validFiles, dirDict] = getTokenDictionary(dirCon,'(\w+)_s(\d+).*_w\d(\w+).*_t(\d+).*\.'); % For SMDA
%[validFiles, dirDict] = getTokenDictionary(dirCon,'g(\d+)_(.*)_s(\d+)_.*tile(\d).*_w\d_(.*)_t(\d+).*\.'); % For SMDA tiling
%[validFiles, dirDict] = getTokenDictionary(dirCon,'g(\d+)_(.*)_s(\d+)_w\d_(.*)_t(\d+).*\.'); % For SMDA new standard
dirCon = dirCon(validFiles);
dirDict = horzcat(dirCon', dirDict);

%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_label','channel_name', 'position_number', 'timepoint'}); %For NIS elements
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_label', 'position_number','channel_name', 'timepoint'});
database = cell2table(dirDict, 'VariableNames', {'filename', 'group_label', 'channel_name', 'position_number', 'timepoint'}); % For metamorph
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_label', 'channel_name', 'position_number', 'timepoint', 'z'}); % For metamorph with z
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_label', 'channel_number', 'position_number'}); % For metamorph scan
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_label', 'position_number', 'channel_name', 'timepoint'}); % For SMDA
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_number', 'group_label', 'position_number', 'tile_number', 'channel_name', 'timepoint'});
%database = cell2table(dirDict, 'VariableNames', {'filename', 'group_number', 'group_label', 'position_number', 'channel_name', 'timepoint'});
writetable(database, outputFilePath, 'Delimiter', '\t');
end