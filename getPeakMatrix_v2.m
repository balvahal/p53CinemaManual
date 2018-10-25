function resultTraces = getPeakMatrix_v2(traces, smoothWindow, delta)
traces_interp = zeros(size(traces));
traces_interp_valleys = zeros(size(traces));
traces_peaks_locs = zeros(size(traces));
traces_valleys_locs = zeros(size(traces));
traces_peaks_values = zeros(size(traces));
traces_valleys_values = zeros(size(traces));

for i=1:size(traces,1)
    try
        smoothTraces = smooth(traces(i,:),smoothWindow)';
        [pks,p] = findpeaks(smoothTraces, 'MinPeakProminence', delta);
        [valleys,v] = findpeaks(-smoothTraces, 'MinPeakProminence', delta);
        
        limit(i) = length(smoothTraces);
        
        if(limit(i) > 0)
            validPoints = p < limit(i);
            p = p(validPoints);
            pks = pks(validPoints);
            validPoints = v < limit(i);
            v = v(validPoints);
            valleys = -valleys(validPoints);
        else
            limit(i) = length(smoothTraces);
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
        interpx = min(p):max(p);
        interpy = interp1(p',y,interpx');
        traces_interp(i, interpx) = interpy;
        
        v = [1,v,size(traces,2)];
        y = traces(i,v);
        
        validPoints = ~isinf(y) & ~isnan(y);
        v = v(validPoints);
        y = y(validPoints);
        interpx = min(v):max(v);
        interpy = interp1(v',y,interpx');
        traces_interp_valleys(i, interpx) = interpy;
    catch e
        a = 1;
    end
end

resultTraces.traces_interp = traces_interp;
resultTraces.traces_peaks_locs = traces_peaks_locs;
resultTraces.traces_valleys_locs = traces_valleys_locs;
resultTraces.traces_peaks_values = traces_peaks_values;
resultTraces.traces_valleys_values = traces_valleys_values;
resultTraces.traces_interp_valleys = traces_interp_valleys;
end