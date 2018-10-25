function [position_correlation, unique_positions] = detectPositionOverlap(database, rawdatapath, channel)
% This algorithm assumes that there are each position has a unique position
% number associated with it.
unique_positions = unique(database.position_number);
position_correlation = zeros(length(unique_positions));
unique_groups = unique(database.group_label);
resizeFactor = 0.5;
for i=1:length(unique_groups)
    fprintf('Working on group %s\n', unique_groups{i});
    currentPositions = unique(database.position_number(strcmp(database.group_label, unique_groups{i})));
    fileInfo = imfinfo(fullfile(rawdatapath, getDatabaseFile2(database, unique_groups{i}, channel, currentPositions(1), 1)));
    currentImageSequence = zeros(floor(fileInfo.Height* resizeFactor), floor(fileInfo.Width* resizeFactor), length(currentPositions));
    for j=1:length(currentPositions)
        IM = imread(fullfile(rawdatapath, getDatabaseFile2(database, unique_groups{i}, channel, currentPositions(j), 1)));
        IM = double(IM);
        IM = imresize(imbackground(IM, 10, 100),resizeFactor);
        currentImageSequence(:,:,j) = IM;
    end
    for j=1:(length(currentPositions)-1)
        IM1 = currentImageSequence(:,:,j);
        index_j = find(unique_positions == currentPositions(j));
        for k=(j+1):length(currentPositions)
            IM2 = currentImageSequence(:,:,k);
            index_k = find(unique_positions == currentPositions(k));
            crosscorrelation = normxcorr2(IM1, IM2);
            position_correlation(index_j, index_k) = max(crosscorrelation(:));
        end
    end
end
end