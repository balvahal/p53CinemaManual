function imageStrip = batchSampleMovies_RGB(database, rawDataPath, centroidsTracks, cell_index, traces, dimensions, outputPath, colorcode, subColorTraces, outputMode)
%Load image sequence
validTimepoints = unique(database.timepoint);

[~,ordering] = sort(database.timepoint);
database = database(ordering,:);

imageInfo = imfinfo(fullfile(rawDataPath, database.filename{1}));
imageSequence = zeros(imageInfo.Height, imageInfo.Width, size(database,1));
progress = 0;
for i=1:size(database,1)
    if(i/size(database,1) > progress + 0.1);
        progress = progress + 0.1;
        fprintf('%d ', round(progress*100));
    end
    IM = imread(fullfile(rawDataPath, database.filename{i}));
    IM = imbackground(IM, 10, 100);
    imageSequence(:,:,i) = IM;
end
fprintf('%d\n', round(progress*100));

if(strcmp(outputMode, 'stack'))
    imageStrip = [];
else
    numTimesteps = length(validTimepoints);
    imageStrip = {zeros(dimensions(1), dimensions(2) * numTimesteps, 3)};
    imageStrip = repmat(imageStrip, length(cell_index), 1);
end
    
for i=1:length(cell_index)
    outputFilename = regexprep(database.filename{1}, '_t\d+', sprintf('_c%d_zoomMovie', cell_index(i)));
    if(exist(fullfile(outputPath, outputFilename), 'file'))
        continue;
    end
    fprintf('%s\n', outputFilename);
    currentCentroids = centroidsTracks.getCellTrack(cell_index(i));
    currentCentroids = currentCentroids(validTimepoints,:);
    if(sum(currentCentroids(:,1) == 0)>0)
        fprintf('%s: Unknown centroids will cause problems. File cannot be generated.\n', outputFilename);
        imageStrip{i} = imageStrip{i} + 1;
        continue;
    end
    if(isempty(traces))
        maxValue = [];
    else
        maxValue = quantile(smooth(traces(i,:)), 0.95);
    end
    singleStrip = createSingleCellMovie_RGB(imageSequence, currentCentroids, maxValue, dimensions, fullfile(outputPath, outputFilename), colorcode, subColorTraces(i,:), outputMode);
    if(~strcmp(outputMode, 'stack'))
        imageStrip{i} = singleStrip;
    end
end

end