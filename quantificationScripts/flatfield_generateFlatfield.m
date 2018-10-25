function [flatfield_gain, flatfield_offset] = flatfield_generateFlatfield(ffpath)
    warning off 'stats:statrobustfit:IterationLimit';
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
        chan = uniqueChannels{i};
        fprintf('Generating flatfield for %s\n', chan);
        chanFiles = strcmp(ffDict(:,1), chan);
        IM_offset = makeoffset(ffpath, chan);
        [IM_gain, max_gain] = makegain(ffpath, ffFiles(chanFiles), str2double(ffDict(chanFiles,2)), chan);
    end
end

%----- SUBFUNCTION LEASTSQUARESFIT -----
function [a,b,r2]=leastsquaresfit(x,y)
xm=mean(x);
ym=mean(y);
SSxx=sum(x.*x)-length(x)*xm^2;
SSyy=sum(y.*y)-length(y)*ym^2;
SSxy=sum(x.*y)-length(x)*xm*ym;
b=SSxy/SSxx;
a=ym-b*xm;
r2=(SSxy^2)/(SSxx*SSyy);
end

%----- SUBFUNCTION XYSMOOTHEN -----
function [I]=xysmoothen(I,windowsize)
    I = imfilter(I, ones(windowsize, windowsize) / windowsize^2, 'replicate');
end

%----- SUBFUNCTION MAKEOFFSET -----
function IM = makeoffset(ffpath, chan)
    filename = fullfile(ffpath, sprintf('%s_0', chan));
    info = imfinfo(filename,'tif');
    IM=double(imread(filename,'tif','Info',info));
    IM=xysmoothen(IM,9);
    IM=floor(IM);
    IM=uint16(IM);
    outputFile = fullfile(ffpath, sprintf('%s_offset.tif', chan));
    imwrite(IM,outputFile,'tif','Compression','none');
end

%----- SUBFUNCTION MAKEGAIN -----
function [IM, max_temp] = makegain(ffpath, filenames, exposure, chan)
    % It is assumed that the filenames and exposures have a 1-to-1
    % correspondence
    info = imfinfo(fullfile(ffpath, filenames{1}),'tif');
    % Allocate more space to put more weight on the dark image
    flatfieldIM = zeros(info.Height, info.Width, length(filenames) + 5);
    % flatfieldIM = cell(length(filenames));
    for i=1:length(filenames)
        flatfieldIM(:,:,i) = double(imread(fullfile(ffpath,filenames{i}),'tif','Info',info));
    end

    %Weight dark image by 5
    ind = find(exposure == 0);
    exposure = [exposure', zeros(1,5)];
    for i=0:4
        flatfieldIM(:,:,end-i) = flatfieldIM(:,:,ind);
    end
    
    %calculate the gain image
    gainIM = zeros(info.Height, info.Width);
    for j=1:info.Height
        for k=1:info.Width
            [x,y]=deal(zeros(length(exposure),1));
            for i=1:length(exposure)
                y(i)=flatfieldIM(j,k,i);
                x(i)=exposure(i);
            end
            [~,b,r2]=leastsquaresfit(x,y);
            if(r2 < 0.8)
                fprintf('Not a good fit for x=%d, y=%d\n', j, k);
            end
            gainIM(j,k)=b;
        end
    end
    gainIM=gainIM/mean(mean(gainIM));
    %gainIM=xysmoothen(gainIM,5);
    max_temp=max(max(gainIM));
    max_temp=round(max_temp*1000)/1000;
    im_temp=gainIM*2^16/max_temp;
    IM=uint16(im_temp);
    imwrite(IM,fullfile(ffpath,sprintf('%s_gain%d.tif',chan,max_temp*1000)),'tif','Compression','none');
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
