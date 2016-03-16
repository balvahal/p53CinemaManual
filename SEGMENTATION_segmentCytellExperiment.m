function [] = SEGMENTATION_segmentCytellExperiment(database, experimentPath, channel)
filesToSegment = find(strcmp(database.channel_name, channel));
parfor i=1:length(filesToSegment)
    currentFile = filesToSegment(i);
    inputFile = database.filename{currentFile};
    if(~exist(fullfile(experimentPath, database.subfolder{currentFile}, 'SEGMENT_DATA'),'dir'))
        mkdir(fullfile(experimentPath, database.subfolder{currentFile}, 'SEGMENT_DATA'));
    end
    outputFile = regexprep(inputFile, '\.', '_segment.');
    IM = imread(fullfile(experimentPath, database.subfolder{currentFile}, inputFile));
    Objects = SEGMENTATION_identifyPrimaryObjectsGeneral(IM);
    imwrite(Objects, fullfile(experimentPath, database.subfolder{currentFile}, 'SEGMENT_DATA', outputFile), 'tif');
end
end