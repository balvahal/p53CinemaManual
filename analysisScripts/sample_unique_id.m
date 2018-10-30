function [validIds, ids] = sample_unique_id(ids)
validIds = true(length(ids),1);
progenitorFreq = tabulate(ids);
repeatedProgenitor = progenitorFreq(progenitorFreq(:,2) > 1,1);
for i=1:length(repeatedProgenitor)
    childCells = find(ids == repeatedProgenitor(i));
    validIds(childCells) = 0;
    validIds(randsample(childCells,1)) = 1;
end
ids = ids(validIds);
end