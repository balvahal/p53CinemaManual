function [] = makeTraceMovie_plotyy(timepoints, trace1, trace2, divisions, outputFile, dimensions, ylimit1, ylimit2, color1, color2, xlab, ylab1, ylab2)
f = figure; plot(timepoints, trace1(1,:)); ylim(ylimit1);
ytickmarks1 = get(gca, 'YTick'); delete(f);
f = figure; plot(timepoints, trace2(1,:)); ylim(ylimit2);
ytickmarks2 = get(gca, 'YTick'); delete(f);

for i=1:length(trace1)
    [hAx,hLine1,hLine2] = plotyy(timepoints(1:i), trace1(1:i), timepoints(1:i), trace2(1:i)); 
    set(hLine1, 'color', color1);
    set(hLine2, 'color', color2);
    
    xlimit = [min(timepoints), max(timepoints)];
    set(hAx(1), 'ylim', ylimit1, 'YTick', [], 'XLim', xlimit, 'ycolor', color1);
    set(hAx(2), 'ylim', ylimit2, 'YTick', [], 'XTick', [], 'Xlim', xlimit, 'ycolor', color2);
    xlabel(hAx(1), xlab, 'FontSize', 8); 
    ylabel(hAx(1), ylab1, 'FontSize', 8); 
    ylabel(hAx(2), ylab2, 'FontSize', 8);
    hold all;
    
    set(gcf, 'Color', 'w'); set(gca, 'FontName', 'Arial', 'FontSize', 8);
    position = get(gcf, 'Position');
    position(3:4) = dimensions;
    set(gcf, 'Position', position);

    divisionTiming = find(divisions);
    if(~isempty(divisionTiming))
        for j=1:length(divisionTiming)
            if(divisionTiming(j) <= i)
                plot(timepoints([divisionTiming(j), divisionTiming(j)]), ylimit1, 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.5);
                text(timepoints(divisionTiming(j) + 2), max(ylimit1) * 0.9, 'Division');
            end
        end
    end
    imageData = getframe(gcf);
    imwrite(imageData.cdata, outputFile, 'tif', 'WriteMode', 'append', 'Compression', 'none');
    hold off;
end
end