function [] = plotnfill_auto_quantiles_fromVectors(xvalues, yvalues, quantiles, color)
    medianValues = grpstats(yvalues, xvalues, @median);
    xval = unique(xvalues)';
    plot(xval, medianValues, 'Color', color); hold all;
    for i=1:length(quantiles)
        q_up = grpstats(yvalues, xvalues, @(x) quantile(x, quantiles(i)))';
        q_down = grpstats(yvalues, xvalues, @(x) quantile(x, 1-quantiles(i)))';
        fill([xval, fliplr(xval)], [q_down, fliplr(q_up)], color, 'FaceAlpha', 0.5/length(quantiles), 'EdgeColor', 'none');
    end
end