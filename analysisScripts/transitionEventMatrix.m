function [matrix_down, matrix_up] = transitionEventMatrix(traces, threshold_up, threshold_down, time_threshold, window, exclude)
thresholded_traces = ones(size(traces));
thresholded_traces(traces > threshold_up | ismember(traces, exclude)) = 2;
thresholded_traces(traces < threshold_down & ~ismember(traces, exclude)) = 0;

matrix_down = zeros(size(traces));
matrix_up = zeros(size(traces));
for i=1:size(traces,1)
    j = time_threshold;
    while(j < size(traces,2))
        frame = findpattern_once(thresholded_traces(i,j:end), zeros(1,window));
        %frame = findpattern(thresholded_traces(i,:), zeros(1,window));
        %frame = frame(frame > j);
        if(~isempty(frame))
            dropEvent = min(frame);
            matrix_down(i,dropEvent + j - 1) = 1;
            j = dropEvent + j - 1;
            frame = findpattern_once(thresholded_traces(i,j:end), 2*ones(1,window));
            %frame = frame(frame > dropEvent);
            if(~isempty(frame))
                j = min(frame) + j;
                matrix_up(i,j) = 1;
            else
                break
            end
        else
            break;
        end
    end
end

end