function normalizedMatrix = normalizeTrajectories(traces, referenceRange)
    normalizedMatrix = traces;
    normalization_values = repmat(mean(traces(:,referenceRange),2), 1, size(traces,2));
    normalizedMatrix = normalizedMatrix ./ normalization_values;
end