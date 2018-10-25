function [] = flatfield_batchFlatfieldCorrect(database, rawdatapath, flatfieldpath, outputpath, channel)
filenames = database.filename(strcmp(database.channel_name, channel),:);
[ffoffset, ffgain] = flatfield_readFlatfieldImages(flatfieldpath, channel);
% ffoffset = imresize(ffoffset, 0.5);
% ffgain = imresize(ffgain, 0.5);
if(strcmp(outputpath, rawdatapath))
    fprintf('This action would overwrite your raw data! Please create a new directory to place flatfield corrected images.\n');
    return;
end
fprintf('Correcting flatfield for %s: ', channel);
progress = 0;
for i=1:length(filenames)
    if(i/length(filenames) > progress)
        fprintf('%d ', round(progress * 100));
        progress = progress + 0.1;
    end
    IM = imread(fullfile(rawdatapath, filenames{i}));
    IM_corrected = uint16(flatfield_correctImage(IM, ffoffset, ffgain));
%     IM_corrected = uint16(imbackground(IM_corrected, 2, 200));
    imwrite(IM_corrected, fullfile(outputpath, filenames{i}), 'TIF', 'Compression', 'none');
end
fprintf('%d\n', round(progress * 100));
end