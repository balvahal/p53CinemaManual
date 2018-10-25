function stripDatabase = imageStripSingleTimepoint(database, rawDataPath, trackingPath, channel_name, timepoint, siz, outputDir, outputDatabase)
    trackingFiles = dir(trackingPath);
    trackingFiles = {trackingFiles(:).name};
    validFiles = regexp(trackingFiles, '\.mat', 'once');
    trackingFiles = trackingFiles(~cellfun(@isempty, validFiles));
    
    stripDatabase = cell(length(trackingFiles), 6);
    
    for i=1:length(trackingFiles)
        fprintf('%s\n', trackingFiles{i});
        load(fullfile(trackingPath, trackingFiles{i}));
        
        filename = getDatabaseFile2(database, selectedGroup, channel_name, selectedPosition, timepoint);
        IM = imread(fullfile(rawDataPath, filename));
        
        [centroids, cell_ids] = centroidsTracks.getCentroids(timepoint);
        if(mod(siz, 2) == 0)
            siz = siz + 1;
        end
        
        outputFile = sprintf('%s_w%s_s%d_t%d.tif', selectedGroup, channel_name, selectedPosition, timepoint);
        
        for j=1:length(cell_ids)
            mask = zeros(siz);
            subImage = GetBlock(IM, centroids(j,1), centroids(j,2), siz);
            mask(1:size(subImage,1), 1:size(subImage,2)) = subImage;
            imwrite(uint16(mask), fullfile(outputDir, outputFile), 'WriteMode', 'Append', 'Compression', 'none');
        end
        
        n = length(cell_ids);
        cellAnnotation = cell(n, 3);
        cellAnnotation(:,1) = repmat({selectedGroup}, n, 1);
        cellAnnotation(:,2) = repmat({selectedPosition}, n, 1);
        cellAnnotation(:,3) = arrayfun(@num2cell, cell_ids);
        
        outputFile2 = sprintf('%s_w%s_s%d_t%d.txt', selectedGroup, channel_name, selectedPosition, timepoint);
        cellAnnotation = cell2table(cellAnnotation, 'VariableNames', {'group_label', 'position_number', 'cell_id'});
        writetable(cellAnnotation, fullfile(outputDir, outputFile2), 'Delimiter', '\t');
        
        stripDatabase{i,1} = outputFile;
        stripDatabase{i,2} = selectedGroup;
        stripDatabase{i,3} = selectedPosition;
        stripDatabase{i,4} = channel_name;
        stripDatabase{i,5} = 1;
        stripDatabase{i,6} = timepoint;
        
    end
    
    stripDatabase = cell2table(stripDatabase, 'VariableNames', {'filename', 'group_label', 'position_number', 'channel_name', 'cell_id', 'timepoint'});
    writetable(stripDatabase, outputDatabase, 'Delimiter', '\t');
end

function [tim]=GetBlock(im,locX,locY,siz)

    hd=(siz-1)/2;
    tim=im(max(1,locX-hd):min(size(im,1),locX+hd),max(1,locY-hd):min(locY+hd,size(im,2)));

end
