function [] = fill_auto(xval, yval, color)
base = min(yval(:));
xval = [min(xval), xval, max(xval)];
yval = [repmat(base, size(yval,1), 1), yval, repmat(base, size(yval,1), 1)];
fill(xval, yval, color, 'EdgeColor', color);
end