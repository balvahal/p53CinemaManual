function IM_rgb = im2rgb(IM)
    IM_normalized = imnormalize(IM);
    IM_rgb = horzcat(IM_normalized, IM_normalized, IM_normalized);
    IM_rgb = reshape(IM_rgb, [size(IM), 3]);
end