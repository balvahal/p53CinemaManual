function [] = plotnfill_auto_sem(xval, dataMatrix, multiplier, color)
yval = mean(dataMatrix);
plot(xval, yval, 'Color', color, 'LineWidth', 2);
xlim([min(xval), max(xval)]);
hold all;
sem = std(dataMatrix) / sqrt(size(dataMatrix,1)) * multiplier;
error = vertcat(yval + sem, yval - sem);
fill([xval, fliplr(xval)], [error(1,:), fliplr(error(2,:))], color, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
end