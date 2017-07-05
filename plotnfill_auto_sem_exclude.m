function [] = plotnfill_auto_sem_exclude(xval, dataMatrix, multiplier, color, exclude)
yval = zeros(1,size(dataMatrix,2));
sem = yval;
for i=1:length(yval)
    validValues = ~ismember(dataMatrix(:,i), exclude);
    yval(i) = mean(dataMatrix(validValues,i));
    sem(i) = std(dataMatrix(validValues,i)) / sqrt(sum(validValues)) * multiplier;
end
plot(xval, yval, 'Color', color, 'LineWidth', 2);
xlim([min(xval), max(xval)]);
hold all;
%errorbar(xval, yval, sem, 'Color', color, 'LineWidth', 1.5);
error = vertcat(yval + sem, yval - sem);
fill([xval(~isnan(error(1,:))), fliplr(xval(~isnan(error(1,:))))], [error(1,~isnan(error(1,:))), fliplr(error(2,~isnan(error(1,:))))], color, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
end