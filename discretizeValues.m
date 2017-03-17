function discretizedValues = discretizeValues(x, binning)
    discretizedValues = (length(binning) + 1) * ones(length(x),1);
    for i=1:length(binning)
        discretizedValues(x < binning(i) & discretizedValues > i) = i;
    end
end