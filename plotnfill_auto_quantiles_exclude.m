function [] = plotnfill_auto_quantiles_exclude(xval, dataMatrix, quantiles, color, exclude)
dataMatrix(dataMatrix == exclude) = NaN;
yval = quantile(dataMatrix,0.5,1);
plot(xval, yval, 'Color', color, 'LineWidth', 2);
xlim([min(xval), max(xval)]);
hold all;
for i=1:length(quantiles)
    error = quantile(dataMatrix,[1-quantiles(i), quantiles(i)],1);
    validPoints = sum(~isnan(error),1) == 2;
    fill([xval(validPoints), fliplr(xval(validPoints))], [error(1,validPoints), fliplr(error(2,validPoints))], color, 'FaceAlpha', 0.5/length(quantiles), 'EdgeColor', 'none');
end
end