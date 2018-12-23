function [] = plotnfill_auto(xval, yval, error_up, error_down, color)
plot(xval, yval, 'Color', color, 'LineWidth', 2);
hold all;
fill([xval, fliplr(xval)], [error_up, fliplr(error_down)], color, 'FaceAlpha', 0.5, 'EdgeColor', 'none');
%fill([xval, fliplr(xval)], [error_up, fliplr(error_down)], color, 'EdgeColor', 'none');
end