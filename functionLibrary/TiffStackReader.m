function IM_stack = TiffStackReader(stackfile)
    %% Read stack file
    warning off MATLAB:imagesci:Tiff:libraryWarning;
    info = imfinfo(stackfile);
    IM_stack = zeros(info(1).Height, info(1).Width, numel(info));
    IM = Tiff(stackfile, 'r');
    for i=1:numel(info)
        IM_stack(:,:,i) = IM.read;
        if ~IM.lastDirectory
            IM.nextDirectory;
        end
    end
end