function [] = batchTraceMovies(timepoints, traces, divisions, annotation, dimensions, outputPath, channel, ylim, color, xlab, ylab)
for i=1:size(traces,1)
    outputFile = sprintf('%s_s%d_c%d_trace_%s.TIF', annotation{i,1}, annotation{i,2}, annotation{i,3}, channel);
    makeTraceMovie(timepoints, traces(i,:), divisions(i,:), fullfile(outputPath, outputFile), dimensions, ylim, color, xlab, ylab)
end
end