function [] = stackToSingleImages(filepath, channel)
    dirCon = dir(filepath);
    dirCon = {dirCon(:).name};
    validFiles = ~cellfun(@isempty, regexp(dirCon, channel)) & cellfun(@isempty, regexp(dirCon, '_z\d\.'));
    dirCon = dirCon(validFiles);
    parfor i = 1:length(dirCon)
        filename = dirCon{i};
        IM = TiffStack(fullfile(filepath, filename));
        for j=1:size(IM.imstack,3)
            singleImage = IM.imstack(:,:,j);
            outputFile = regexprep(filename, '\.', sprintf('_z%d.', j));
            imwrite(uint16(singleImage), fullfile(filepath, outputFile), 'tiff', 'compression', 'none');
        end
    end
end