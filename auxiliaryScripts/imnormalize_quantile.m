function IM_normalized = imnormalize_quantile(IM, q)
    IM = double(IM);
    IM_normalized = (IM - min(IM(:))) / (quantile(IM(:), q));
    IM_normalized(IM_normalized > 1) = 1;
end