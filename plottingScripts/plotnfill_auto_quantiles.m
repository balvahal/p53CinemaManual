function [] = plotnfill_auto_quantiles(xval, dataMatrix, quantiles, color)
yval = quantile(dataMatrix,0.5,1);
plot(xval, yval, 'Color', color, 'LineWidth', 2);
xlim([min(xval), max(xval)]);
hold all;
for i=1:length(quantiles)
    error = quantile(dataMatrix,[1-quantiles(i), quantiles(i)],1);
    fill([xval, fliplr(xval)], [error(1,:), fliplr(error(2,:))], color, 'FaceAlpha', 0.5/length(quantiles), 'EdgeColor', 'none');
    %fill([xval, fliplr(xval)], [error(1,:), fliplr(error(2,:))], color, 'EdgeColor', 'none');
end
end