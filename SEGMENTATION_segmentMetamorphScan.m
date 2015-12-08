function [] = SEGMENTATION_segmentMetamorphScan(database, rawdatapath, segmentpath, segmentationChannelNumber)
filesToSegment = find(database.channel_number == segmentationChannelNumber);
parfor i=1:length(filesToSegment)
    inputFile = database.filename{filesToSegment(i)};
    outputFile = regexprep(inputFile, '_w\d.*?_s', '_s');
    IM = imread(fullfile(rawdatapath, inputFile));
    Objects = SEGMENTATION_identifyPrimaryObjectsGeneral(IM);
    imwrite(Objects, fullfile(segmentpath, outputFile), 'tif');
end
end