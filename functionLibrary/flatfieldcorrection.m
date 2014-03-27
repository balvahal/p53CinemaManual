function [] = flatfieldcorrection(sourcepath, ffpath, targetpath)
    warning off 'stats:statrobustfit:IterationLimit';
    if ~exist targetpath
        mkdir(targetpath);
    end
    % Encode the contents of the raw files directory
    sourceFiles = dir(sourcepath);
    sourceFiles = {sourceFiles.name};
    [validStrings, sourceDict] = getTokenDictionary(sourceFiles, '(\w)+?_w(\d)(\w+).*?_s(\d+)_t(\d+)');
    sourceFiles = sourceFiles(validStrings);
    % Encode contents of the FLATFIELD directory
    ffFiles = dir(ffpath);
    ffFiles = {ffFiles.name};
    [validStrings, ffDict] = getTokenDictionary(ffFiles, '(\w+)_(\d+)');
    ffFiles = ffFiles(validStrings);
    % Identify unique channels
    % For each channel we will generate an offset and gain image and use
    % this to flatfield correct all of the images that correspond to such
    % channel.
    uniqueChannels = unique(ffDict(:,1));
    for i=1:length(uniqueChannels)
        offsetImage = makeoffset(uniqueChannels(i), ffpath);
        indexes = find(strcmp(ffDict(:,1), uniqueChannels(i)));
        exposure = cellfun(@str2num, ffDict(indexes,2));
        [offsetImage, gainImage] = makegain(uniqueChannels(i), ffpath, ffFiles(indexes), exposure);
        targetImages = find(strcmp(sourceDict(:,2), uniqueChannels(i)));
        for imageIndex = targetImages
            filename = regexp(sourceFiles{imageIndex}, '(.*)?\.tif', 'tokens', 'once');
            outputFile = fullfile(targetpath, [filename '_ff.tif']);
            IM = imread(fullfile(sourcepath, sourceFiles{imageIndex}));
            IM = scale12to16bit(IM);
            IM = IM - offsetImage;
            IM(IM < 0) = 0;
            IM = IM ./ gainImage;
            IM = uint16(IM);
            imwrite(IM,outputFile,'tif','WriteMode','append','Compression','none');
        end
    end
    
end

%----- SUBFUNCTION SCALE12TO16BIT -----
function [IM] = scale12to16bit(IM)
%input:
%IM = an image with bit depth 12
%
%output:
%IM = a scaled image with bit depth 16
%description:
%The class of the image is detected. Depending on the class type an image
%maybe converted into an integer format and then converted back into the
%format of the input.
%
%other notes:
%The Hamamatsu cameras for the closet scope and curtain scope create images
%with 12-bit dynamic range. However, the TIFF format that stores these
%images uses a 16-bit format. Viewing a 12-bit image in a 16-bit format on
%a computer monitor is complicated by the scaling being done at 16-bit. To
%make viewing images from the microscope easier on a computer monitor,
%without any compression or loss of data, the 12-bit data is shifted left
%4-bits to become 16-bit data.
numType = class(IM);
switch numType
    case 'double'
        IM = uint16(IM);
        IM = bitshift(IM,4);
        IM = double(IM);
    case 'uint16'
        IM = bitshift(IM,4);
end
end

%----- SUBFUNCTION makeoffset -----
function IM = makeoffset(chan,ffpath)
filename = fullfile(ffpath, [chan, '_0.tif']);
info = imfinfo(filename);
IM=double(imread(filename,'tif','Info',info));
IM=imfilter(IM, ones(10,10)/100, 'replicate');
IM=floor(IM);
IM=uint16(IM);
imwrite(IM,fullfile(ffpath, [chan, '_offset.tif']),'tif','Compression','none');
end

%----- SUBFUNCTION MAKEGAIN -----
function [offsetIM, gainIM] = makegain(chan,ffpath,ffFiles, exposure)
[exposure,order] = sort(exposure);
ffFiles = ffFiles(order);
info = imfinfo(fullfile(ffpath, ffFiles{1}));

gradientImages = zeros(info.Height, info.Width, length(exposure));
for i=1:length(exposure)
    gradientImages(:,:,i) = imread(fullfile(ffpath, ffFiles{i}));
end

gainIM = zeros(info.Height, info.Width);
offsetIM = zeros(info.Height, info.Width);
for i = 1:info.Height
    disp(i);
    for j = 1:info.Width
        fitResult = robustfit(exposure, reshape(gradientImages(i,j,:), size(exposure)), 'huber');
        gainIM(i,j) = fitResult(2);
        offsetIM(i,j) = fitResult(1);
    end
end
gainIM=imfilter(gainIM, ones(10,10)/100, 'replicate');
max_temp=round(max(max(gainIM)) * 1000) / 1000;
im_temp=gainIM/max_temp*65536;
im_temp=uint16(im_temp);

imwrite(im_temp,fullfile(ffpath, [chan, '_gain.tif']),'tif','Compression','none');
imwrite(offsetIM,fullfile(ffpath, [chan, '_offset.tif']),'tif','Compression','none');
end