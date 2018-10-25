function [mean_x, p_event, sem_event, indexes, numel_event, numel_id] = probabilityEvent(xvals, event, binning, ids)
    discretized_x = discretizeValues(xvals, binning);
    mean_x = grpstats(xvals, discretized_x, 'mean');
    p_event = grpstats(event, discretized_x, 'mean');
    sem_event = grpstats(xvals, discretized_x, 'sem');
    indexes = grpstats(discretized_x, discretized_x, 'mean');
    numel_event = grpstats(xvals, discretized_x, 'numel');
    numel_id = grpstats(ids, discretized_x, @(x) length(unique(x)));
end