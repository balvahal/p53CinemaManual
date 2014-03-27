function [] = extractImages(source, target, prefix)
channels = {'w1DAPI', 'w2GFP', 'w3TexasRed', 'w4Cy5'};

dirCon = dir(source);
dirCon = {dirCon(:).name};
[validFiles, ~] = getTokenDictionary(dirCon, 'tile_x(\d+)_y(\d+)\.tif');
dirCon = dirCon(validFiles);

if(~exist(target, 'dir'))
    mkdir(target);
end

fprintf('%s\n', prefix);
progress = 0;
imageCounter = 1;
for i=1:length(dirCon)
    if(uint16(i/length(dirCon) * 100) >= progress)
        fprintf('%d ', progress);
        progress = progress + 10;
    end
    suffix = regexprep(dirCon{i}, 'tile', '');
    suffix = regexprep(suffix, '\.tif', ['_t', num2str(imageCounter), '.tif']);
    imageCounter = imageCounter + 1;
    for j=1:length(channels)
        IM = imread(fullfile(source, dirCon{i}), j);
        filename = strcat(prefix, '_', channels{j}, suffix);
        imwrite(IM, fullfile(target, filename), 'tif', 'Compression', 'none');
    end
end
fprintf('\n');
end