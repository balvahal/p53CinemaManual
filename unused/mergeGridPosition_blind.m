function mergingCoordinates = mergeGridPosition_blind(database, rawdatapath, outputpath, group, positions, processChannel, ffpath)
    % Merge images channel by channel
    uniqueChannels = unique(database.channel_name(database.position_number == max(positions)));
    for c=1:length(uniqueChannels)
        timepointList = unique(database.timepoint(database.position_number == max(positions) & strcmp(database.channel_name, uniqueChannels{c})));
%         if(ismember(uniqueChannels(c), processChannel))
%             [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, uniqueChannels{c});
%         end
        for t=1:length(timepointList)
            filename = getDatabaseFile2(database, group, uniqueChannels{c}, positions(1), timepointList(t));
            newFilename = regexprep(filename, '_position\d+tile\d+', '');
            %newFilename = regexprep(newFilename, '(.*)_s', '$1_merged_s');
            if(~exist(fullfile(outputpath, newFilename), 'file'))
                for i=1:4
                    filename = getDatabaseFile2(database, group, uniqueChannels{c}, positions(i), timepointList(t));
                    IM = imread(fullfile(rawdatapath, filename));
                    if(ismember(uniqueChannels(c), processChannel))
                        %                     IM = flatfield_correctImage(IM, ff_offset, ff_gain);
                        IM = imbackground(IM, 20, 80);
                    end
                    images{i} = IM;
                end
                temp1 = vertcat(images{1}, zeros(10, size(images{1},2)), images{3});
                temp2 = vertcat(images{2}, zeros(10, size(images{2},2)), images{4});
                mergedImage = horzcat(temp1, zeros(size(temp1,1), 10), temp2);
                imwrite(uint16(mergedImage), fullfile(outputpath, newFilename), 'tif', 'Compression', 'none');
            end
        end
    end
    
end