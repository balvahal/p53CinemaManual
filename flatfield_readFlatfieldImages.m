function [ff_offset, ff_gain] = flatfield_readFlatfieldImages(ffpath, measured_channel)
    % Prepare flatfield images
    ffdirCon = dir(ffpath);
    ffdirCon = {ffdirCon(:).name};
    if(sum(~cellfun(@isempty, regexp(ffdirCon, sprintf('%s_gain', measured_channel),'once'))) == 0 || ... 
            sum(~cellfun(@isempty,regexp(ffdirCon, sprintf('%s_offset', measured_channel),'once'))) == 0)
        flatfield_generateFlatfield(ffpath);
    end
    ff_offset = imread(fullfile(ffpath, sprintf('%s_offset.tif', measured_channel)));
    gainFile = ffdirCon{~cellfun(@isempty,regexp(ffdirCon, sprintf('%s_gain', measured_channel),'once'))};
    ff_gain = imread(fullfile(ffpath, gainFile));
    maxTemp = regexp(gainFile, 'gain(\d+)\.', 'tokens');
    maxTemp = str2double(maxTemp{1}) / 1000;
    ff_gain = double(double(ff_gain) * maxTemp / 2^16);
    
    % Correct for binning
    ff_gain = imresize(ff_gain / 4, 2);
    ff_offset = imresize(ff_offset / 4, 2);
end