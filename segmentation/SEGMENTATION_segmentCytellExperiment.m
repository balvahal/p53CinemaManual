function [] = SEGMENTATION_segmentCytellExperiment(database, rawDataPath, segmentDataPath, channel)
filesToSegment = find(strcmp(database.channel_name, channel));
parfor i=1:length(filesToSegment)
    currentFile = filesToSegment(i);
    inputFile = database.filename{currentFile};
    if(~exist(fullfile(segmentDataPath, database.subfolder{currentFile}),'dir'))
        mkdir(fullfile(segmentDataPath, database.subfolder{currentFile}));
    end
    outputFile = regexprep(inputFile, '\.', '_segment.');
    if(~exist(fullfile(segmentDataPath, outputFile), 'file'))
        IM = imread(fullfile(rawDataPath, inputFile));
        %IM = imread(fullfile(experimentPath, inputFile));
        IM = imbackground(IM, 10, 100);
        Objects = SEGMENTATION_identifyPrimaryObjectsGeneral(IM, 'AreaThreshold', 300, 'MinimumThreshold', 25);
        imwrite(Objects, fullfile(segmentDataPath, outputFile), 'tif');
    end
end
end