function [] = getMaximumProjection_fromStack(database, filepath, channel)
    dirCon = dir(filepath);
    dirCon = {dirCon(:).name};
    %[validFiles, ~] = getTokenDictionary(dirCon, ['_w\d(' channel ')']);
    [validFiles, ~] = getTokenDictionary(dirCon, ['(' channel ')']);
    dirCon = dirCon(validFiles);
    for i = 1:length(dirCon)
        filename = dirCon{i};
        IM = TiffStack(fullfile(filepath, filename));
        maxProj = IM.maxProjection;
        outputFile = regexprep(filename, channel, [channel 'maxProj']);
        imwrite(uint16(maxProj), fullfile(filepath, outputFile), 'tiff', 'compression', 'none');
    end
end