function discretizedValues = discretizeValues(x, binning)
    discretizedValues = (length(binning) + 1) * ones(length(x),1);
    for i=1:length(binning)
        subCells = x <= binning(i) & discretizedValues > i;
        if(~isempty(subCells))
            discretizedValues(subCells) = i;
        end
    end
end