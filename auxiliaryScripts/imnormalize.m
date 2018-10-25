function IM_normalized = imnormalize(IM)
    IM = double(IM);
    IM_normalized = (IM - min(IM(:))) / (max(IM(:)) - min(IM(:)));
    IM_normalized = (IM - min(IM(:))) / (max(IM(:)));
end