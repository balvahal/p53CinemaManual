function [] = makeTraceMovie(timepoints, trace, divisions, outputFile, dimensions, ylimit, color, xlab, ylab)
for i=1:length(trace)
    plot(timepoints((i):end), trace((i):end), 'Color', [1, 1, 1], 'LineSmoothing', 'off'); ylim(ylimit); xlim([min(timepoints), max(timepoints)]);
    set(gcf, 'Color', 'w'); set(gca, 'FontName', 'Arial', 'FontSize', 12);
    position = get(gcf, 'Position');
    position(3:4) = dimensions;
    set(gcf, 'Position', position);
    xlabel(xlab, 'FontName', 'Arial', 'FontSize', 12);
    ylabel(ylab, 'FontName', 'Arial', 'FontSize', 12);
    hold all;
    plot(timepoints(1:i), trace(1:i), 'Color', color, 'LineWidth', 1.5, 'LineSmoothing', 'off');
    hold all;
    divisionTiming = find(divisions);
    if(~isempty(divisionTiming))
        for j=1:length(divisionTiming)
            if(divisionTiming(j) <= i)
                plot(timepoints([divisionTiming(j), divisionTiming(j)]), ylim, 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.5);
                text(timepoints(divisionTiming(j) + 2), max(ylimit) * 0.9, 'Division');
            end
        end
    end
    imageData = getframe(gcf);
    imwrite(imageData.cdata, outputFile, 'tif', 'WriteMode', 'append', 'Compression', 'none');
    hold off;
end
end