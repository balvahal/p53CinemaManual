function traces = fillMatrixHoles(traces)
    for i=1:size(traces,1)
        traces(i,:) = fillTraceHoles(traces(i,:));
    end
end