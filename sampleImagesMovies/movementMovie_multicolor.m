% This function only has support for Matlab 2014b or higher due to the use
% of transparency
function [] = movementMovie_multicolor(centroids_col, centroids_row, window, colors, outputFile)
validColumns = sum(centroids_col > -1,1) > 0;
centroids_col = centroids_col(:,validColumns);
centroids_row = centroids_row(:,validColumns);

alpha = fliplr((1/window):(1/window):1);

figure; set(gcf,'Color','w');
figurePosition = get(gcf, 'Position');
figurePosition(3:4) = [400,400];
set(gcf, 'Position', figurePosition);
axis(); set(gca, 'XTick', [], 'YTick', []); box on; axis square; set(gca, 'Position', [0,0,1,1]);
ylim([1,max(centroids_col(:))]); xlim([1,max(centroids_row(:))]);
hold all;

for i=2:size(centroids_row,2)
    fprintf('Frame %d\n',i);
    for k=1:size(centroids_row,1)
        alphaValue = 1;
        for j=fliplr(max(2,i-(window-1)):i)
            if(centroids_col(k,(j-1)) > 0 && centroids_col(k,(j)) > 0)
                line(centroids_col(k,(j-1):j)',centroids_row(k,(j-1):j)','Color',[colors(k,:), alpha(alphaValue)]); hold all;
            end
            alphaValue = alphaValue + 1;
        end
    end
    imageData = getframe(gcf);
    imwrite(imageData.cdata, outputFile, 'tif', 'WriteMode', 'append', 'Compression', 'none');
    cla;
end
end