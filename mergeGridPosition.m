function mergingCoordinates = mergeGridPosition(database, rawdatapath, outputpath, group, positions, uniqueChannels, mergingChannel, processChannel, ffpath)
    % Figure out stitching coordinates
    timepointList = unique(database.timepoint(database.position_number == max(positions) & strcmp(database.channel_name, mergingChannel)));
    
    % Record image parameters
    sampleFile = getDatabaseFile(database, mergingChannel, positions(1), timepointList(1));
    info = imfinfo(fullfile(rawdatapath, sampleFile));
    height = info.Height;
    width = info.Width;
    images = repmat({zeros(height, width)},4,1);
    
    % Sample timepoints to get stitching coordinates
    sampleSkipping = 5;
    coordinateSampling = zeros(round(length(timepointList)/sampleSkipping),16);
    counter = 1;
    for i=1:sampleSkipping:length(timepointList);
        fprintf('%d\n', i);
        for j=1:4
            filename = getDatabaseFile2(database, group, mergingChannel, positions(j), timepointList(i));
            images{j} = imread(fullfile(rawdatapath, filename));
        end
        try
            [c1, c2, temp1] = imstitchvert(images{1}, images{3});
            [c11, c22, temp2] = imstitchvert(images{2}, images{4});
            temp2 = vertcat(imsubimage_rowcol(images{2}, c1), imsubimage_rowcol(images{4},c2));
            [c3, c4, outputImage] = imstitchhorz(temp1, temp2);
            
%             temp1 = vertcat(imsubimage_rowcol(images{1}, c1), imsubimage_rowcol(images{3},c2));
%             temp2 = vertcat(imsubimage_rowcol(images{2}, c11), imsubimage_rowcol(images{4},c22));
%             outputImage = horzcat(imsubimage_rowcol(temp1, c3), imsubimage_rowcol(temp2, c4));

            coordinateSampling(counter,:) = [c1, c2, c3, c4];
            counter = counter + 1;
        catch e
            fprintf('%s\n', e.getReport);
        end
    end
    coordinateSampling = coordinateSampling(1:counter-1,:);
   
    % Obtain consensus from the sampling results (find the most common row)
    [uniqueRows, frequency] = unique(coordinateSampling, 'rows');
    [~,maxfreq] = max(frequency);
    consensusCoordinates = uniqueRows(maxfreq,:);
    mergingCoordinates = {consensusCoordinates(1:4), consensusCoordinates(5:8), consensusCoordinates(9:12), consensusCoordinates(13:16)};
    
    % Merge images channel by channel
    %uniqueChannels = unique(database.channel_name(database.position_number == max(positions)));
    for c=1:length(uniqueChannels)
        timepointList = unique(database.timepoint(database.position_number == max(positions) & strcmp(database.channel_name, uniqueChannels{c})));
%         if(ismember(uniqueChannels(c), processChannel))
%             [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, uniqueChannels{c});
%         end
        for t=1:length(timepointList)
            for i=1:4
                filename = getDatabaseFile(database, uniqueChannels{c}, positions(i), timepointList(t));
                IM = imread(fullfile(rawdatapath, filename));
                if(ismember(uniqueChannels(c), processChannel))
%                     IM = flatfield_correctImage(IM, ff_offset, ff_gain);
                    IM = imbackground(IM, 10, 60);
                end
                images{i} = IM;
            end
            mergedImage = mergeImageGrid(images{1}, images{2}, images{3}, images{4}, mergingCoordinates);
%             temp1 = vertcat(imsubimage_rowcol(images{1}, c1), imsubimage_rowcol(images{3},c2));
%             temp2 = vertcat(imsubimage_rowcol(images{2}, c11), imsubimage_rowcol(images{4},c22));
%             mergedImage = horzcat(imsubimage_rowcol(temp1, c3), imsubimage_rowcol(temp2, c4));
            
            newFilename = regexprep(filename, '(.*)_w', '$1_merged_w');
            imwrite(uint16(mergedImage), fullfile(outputpath, newFilename), 'tif', 'Compression', 'none');
        end
    end
    
end