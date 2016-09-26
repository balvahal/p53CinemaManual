function [] = getMaximumProjection_fromStack(filepath, channel)
    dirCon = dir(filepath);
    dirCon = {dirCon(:).name};
    %[validFiles, ~] = getTokenDictionary(dirCon, ['_w\d(' channel ')']);
    [validFiles, ~] = getTokenDictionary(dirCon, ['(' channel ')']);
    dirCon = dirCon(validFiles);
    for i = 1:length(dirCon)
        filename = dirCon{i};
        outputFile = regexprep(filename, channel, [channel 'maxProj']);
        if(~exist(fullfile(filepath, outputFile), 'file') && isempty(regexp(filename, 'maxProj')))
            IM = TiffStack(fullfile(filepath, filename));
            maxProj = IM.maxProjection;
            imwrite(uint16(maxProj), fullfile(filepath, outputFile), 'tiff', 'compression', 'none');
        end
    end
end