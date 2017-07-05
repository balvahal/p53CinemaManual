function resultTraces = getPeakMatrix(traces, limit, smoothWindow)
traces_interp = zeros(size(traces));
traces_peaks_locs = zeros(size(traces));
traces_valleys_locs = zeros(size(traces));
traces_peaks_values = zeros(size(traces));
traces_valleys_values = zeros(size(traces));

for i=1:size(traces,1)
    smoothTraces = smooth(traces(i,:),smoothWindow)';
    [pks,p] = findpeaks(smoothTraces);
    
    [valleys,v] = findpeaks(-smoothTraces);
    if(limit(i) > 0)
        validPoints = p < limit(i);
        p = p(validPoints);
        pks = pks(validPoints);
        validPoints = v < limit(i);
        v = v(validPoints);
        valleys = valleys(validPoints);
    end
    traces_peaks_locs(i,p) = 1;
    traces_peaks_values(i,p) = traces(i,p);
    traces_valleys_locs(i,v) = 1;
    traces_valleys_values(i,v) = traces(i,v);
    
    p = [1,p,size(traces,2)];
    y = traces(i,p);
    
    validPoints = ~isinf(y) & ~isnan(y);
    p = p(validPoints);
    y = y(validPoints);
    %y = smoothTraces(p);
    interpx = min(p):max(p);
    interpy = interp1(p',y,interpx');
    traces_interp(i, interpx) = interpy;
end

resultTraces.traces_interp = traces_interp;
resultTraces.traces_peaks_locs = traces_peaks_locs;
resultTraces.traces_valleys_locs = traces_valleys_locs;
resultTraces.traces_peaks_values = traces_peaks_values;
resultTraces.traces_valleys_values = traces_valleys_values;

end