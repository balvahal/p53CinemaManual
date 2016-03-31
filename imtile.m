function IM = imtile(database, rawdatapath, group, channel, timepoint, ncol, resizeFactor, tileMode)
database = database(strcmp(database.group_label, group) & strcmp(database.channel_name, channel) & (database.timepoint == timepoint),:);
info = imfinfo(fullfile(rawdatapath, database.filename{1}));
imwidth = round(info.Width * resizeFactor);
imheight = round(info.Height * resizeFactor);

uniquePositions = unique(database.position_number);
nrow = round(length(uniquePositions) / ncol);

IM = uint16(zeros(nrow * imheight, ncol * imwidth));

counter = 1;
rowIndex = 1;
for i=1:nrow
    tempStrip = zeros(imheight, ncol * imwidth);
    colIndex = 1;
    for j=1:ncol
        currentImage = imresize(imread(fullfile(rawdatapath, database.filename{database.position_number == uniquePositions(counter)})), resizeFactor);
        counter = counter + 1;
        if(strcmp(tileMode, 'snake'))
            currentImage = fliplr(currentImage);
        end
        tempStrip(:,colIndex:(colIndex + imwidth - 1)) = currentImage;
        colIndex = colIndex + imwidth;
    end
    if(strcmp(tileMode, 'snake'))
        tempStrip = fliplr(tempStrip);
    end
    IM(rowIndex:(rowIndex + imheight - 1),:) = tempStrip;
    rowIndex = rowIndex + imheight;
end
end