function [] = plotTracePeaks(traces, peaks, index)
    plot(traces(index,:));
    hold all;
    pks = find(peaks.traces_peaks_locs(index,:));
    if(~isempty(pks))
        plot(pks, peaks.traces_peaks_values(index, pks), 'o', 'Color', 'm');
    end
    valleys = find(peaks.traces_valleys_locs(index,:));
    if(~isempty(valleys))
        plot(valleys, peaks.traces_valleys_values(index, valleys), 'o', 'Color', 'r');
    end
end