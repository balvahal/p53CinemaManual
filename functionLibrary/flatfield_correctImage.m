function correctedImage = flatfield_correctImage(ffpath, filename, varargin)
    
    p = inputParser;
    p.addRequired('ffpath', @(x)ischar(x));
    p.addRequired('filename', @(x)ischar(x));
    addOptional(p,'channel','',@(x)ischar(x))
    p.parse(ffpath, varargin{:});
    
    if(strcmp(p.Results.channel, ''))
        channel = regexp(filename, '_w\d(\w+)', 'tokens', 'once');
        channel = channel{1};
    else
        channel = p.Results.channel;
    end
    
    offsetImage = imread(fullfile(ffpath, [channel '_offset.tif']));
    gainImage = imread(fullfile(ffpath, [channel '_gain.tif']));
    gainInfo = imfinfo(fullfile(ffpath, [channel '_gain.tif']));
    max_temp = str2double(gainInfo.ImageDescription);

    gainImage = double(gainImage);
    gainImage = gainImage * max_temp / 65536;
    
    IM = double(imread(fullfile(filename)));
    
    if(size(gainImage,1) ~= size(IM,1))
        gainImage = imresize(gainImage, size(IM), 'bilinear');
        offsetImage = imresize(offsetImage, size(IM), 'bilinear');
    end
    
    IM = double(IM) - double(offsetImage);
    IM(IM < 0) = 0;
    IM = IM ./ gainImage;
    correctedImage = uint16(IM);

end