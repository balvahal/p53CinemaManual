function trace = fillTraceHoles(trace)
    activeTimepoints = find(trace > -1,1,'first'):find(trace > -1,1,'last');
    while(sum(trace(activeTimepoints) < 0) > 0)
        holeStart = find(trace(activeTimepoints) < 0, 1, 'first') + activeTimepoints(1) - 2;
        holeEnd = find(trace((holeStart+1):activeTimepoints(end)) > -1, 1, 'first') + holeStart;
        interpolated = interp1([holeStart, holeEnd], trace([holeStart, holeEnd]), holeStart:holeEnd);
        trace(holeStart:holeEnd) = interpolated;
    end
end