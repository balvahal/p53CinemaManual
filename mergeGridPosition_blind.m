function mergingCoordinates = mergeGridPosition_blind(database, rawdatapath, outputpath, group, positions, processChannel, ffpath)
    % Merge images channel by channel
    uniqueChannels = unique(database.channel_name(database.position_number == max(positions)));
    for c=1:length(uniqueChannels)
        timepointList = unique(database.timepoint(database.position_number == max(positions) & strcmp(database.channel_name, uniqueChannels{c})));
%         if(ismember(uniqueChannels(c), processChannel))
%             [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, uniqueChannels{c});
%         end
        for t=1:length(timepointList)
<<<<<<< HEAD
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
=======
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
%             temp1 = vertcat(imsubimage_rowcol(images{1}, c1), imsubimage_rowcol(images{3},c2));
%             temp2 = vertcat(imsubimage_rowcol(images{2}, c11), imsubimage_rowcol(images{4},c22));
%             mergedImage = horzcat(imsubimage_rowcol(temp1, c3), imsubimage_rowcol(temp2, c4));
            
            newFilename = regexprep(filename, '_position\d+', '');
            newFilename = regexprep(newFilename, '_*tile\d+', '');
            newFilename = regexprep(newFilename, '(.*)_s', '$1_merged_s');
            imwrite(uint16(mergedImage), fullfile(outputpath, newFilename), 'tif', 'Compression', 'none');
>>>>>>> origin/master
        end
    end
    
end