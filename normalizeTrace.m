function nt = normalizeTrace(t)
    nt = t - min(t(~isnan(t)));
    nt = nt / max(t(~isnan(t)));
end