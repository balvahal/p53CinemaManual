function [] = getMaximumProjection_fromStack_flatfield(filepath, channel, ffpath)
    dirCon = dir(filepath);
    dirCon = {dirCon(:).name};
    %[validFiles, ~] = getTokenDictionary(dirCon, ['_w\d(' channel ')']);
    [validFiles, ~] = getTokenDictionary(dirCon, ['(' channel ')']);
    dirCon = dirCon(validFiles);
    [ffoffset, ffgain] = flatfield_readFlatfieldImages(ffpath, channel);
    ffoffset = imfilter(ffoffset, fspecial('gaussian', 5, 2), 'replicate');
    ffgain = imfilter(ffgain, fspecial('gaussian', 5, 2), 'replicate');
    for i = 1:length(dirCon)
        filename = dirCon{i};
        outputFile = regexprep(filename, channel, [channel 'maxProj']);
        %if(~exist(fullfile(filepath, outputFile), 'file') && isempty(regexp(filename, 'maxProj')))
        if(isempty(regexp(filename, 'maxProj')))
            IM = TiffStack(fullfile(filepath, filename));
%             IM = IM.correctFlatfield(ffoffset, ffgain);
            maxProj = IM.maxProjection;
            imwrite(uint16(maxProj), fullfile(filepath, outputFile), 'tiff', 'compression', 'none');
        end
    end
end