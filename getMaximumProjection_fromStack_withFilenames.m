function [] = getMaximumProjection_fromStack_withFilenames(filepath, filenames, channel)
    for i = 1:length(filenames)
        filename = filenames{i};
        IM = TiffStack(fullfile(filepath, filename));
        maxProj = IM.maxProjection;
        outputFile = regexprep(filename, channel, [channel 'maxProj']);
        imwrite(uint16(maxProj), fullfile(filepath, outputFile), 'tiff', 'compression', 'none');
    end
end