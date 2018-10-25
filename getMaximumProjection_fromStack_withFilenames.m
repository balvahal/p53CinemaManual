function [] = getMaximumProjection_fromStack_withFilenames(filepath, filenames, channel)
    parfor i = 1:length(filenames)
        filename = filenames{i};
        outputFile = regexprep(filename, channel, [channel 'maxProj']);
        if(~exist(fullfile(filepath, outputFile), 'file') && isempty(regexp(filename, 'maxProj')))
            IM = TiffStack(fullfile(filepath, filename));
            maxProj = IM.maxProjection;
            imwrite(uint16(maxProj), fullfile(filepath, outputFile), 'tiff', 'compression', 'none');
        end
    end
end