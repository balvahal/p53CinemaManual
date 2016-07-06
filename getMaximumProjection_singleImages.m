function [] = getMaximumProjection_singleImages(filepath, channel)
    dirCon = dir(filepath);
    dirCon = {dirCon(:).name};
    [validFiles, dirDict] = getTokenDictionary(dirCon, ['s(\d+).*_w.*' channel '.*_z(\d+)']);
    dirCon = dirCon(validFiles);
    uniquePositions = unique(dirDict(:,1));
    for i=1:length(uniquePositions)
        currentFiles = dirCon(strcmp(dirDict(:,1), uniquePositions{i}));
        IM = imread(fullfile(filepath, currentFiles{1}));
        maximaImage = IM;
        for j=2:length(currentFiles)
            IM = imread(fullfile(filepath, currentFiles{j}));
            maximaImage = bsxfun(@max, IM, maximaImage);
        end
        outputName = currentFiles{1};
        outputName = regexprep(outputName, '_z\d+', '_z0');
        imwrite(uint16(maximaImage), fullfile(filepath, outputName), 'tif', 'Compression', 'none');
    end
end