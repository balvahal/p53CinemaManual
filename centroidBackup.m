function [] = centroidBackup(centroidPath)
files = dir(centroidPath);
files = {files(:).name};
files = files(~cellfun(@isempty,regexp(files,'\.mat')));
for i=1:length(files)
    load(fullfile(centroidPath, files{i}));
    myTable = centroids2table_withDivisions(centroidsTracks, centroidsDivisions);
    outputFile = regexprep(files{i}, '\.mat', '.txt');
    writetable(myTable, fullfile(centroidPath, outputFile), 'Delimiter', '\t');
end
end