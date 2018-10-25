function [] = batchSampleMovies_followCells(database, rawDataPath, centroidsTracks, cell_index, traces, dimensions, outputPath)
%Load image sequence
validTimepoints = unique(database.timepoint);

[~,ordering] = sort(database.timepoint);
database = database(ordering,:);

imageInfo = imfinfo(fullfile(rawDataPath, database.filename{1}));
imageSequence = zeros(imageInfo.Height, imageInfo.Width, size(database,1));
for i=1:size(database,1)
    IM = imread(fullfile(rawDataPath, database.filename{i}));
    %IM = imbackground(IM, 10, 100);
    imageSequence(:,:,i) = IM;
end

for i=1:length(cell_index)
    outputFilename = regexprep(database.filename{1}, '_t\d+', sprintf('_c%d_zoomMovie', cell_index(i)));
    if(exist(fullfile(outputPath, outputFilename), 'file'))
        continue;
    end
    fprintf('%s\n', outputFilename);
    currentCentroids = centroidsTracks.getCellTrack(cell_index(i));
    currentCentroids = currentCentroids(validTimepoints,:);
    createSingleCellMovie_followCells(imageSequence, currentCentroids, [], dimensions, fullfile(outputPath, outputFilename));
end

end