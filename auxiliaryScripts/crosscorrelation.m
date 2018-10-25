function output = crosscorrelation(trace1, trace2, range)
    trimming
    output = zeros(length(range), 1);
    valid_elements1 = trace1 > -1;
    valid_elements2 = trace2 > -1;
    mean_value = [mean(trace1(valid_elements1)), mean(trace2(valid_elements2))];
    var_value = [var(trace1(valid_elements1)),var(trace2(valid_elements2))];
    for tau_index = 1:length(range)
        tau = range(tau_index);
        max_index = length(trace1) - tau;
        trace_present = trace1(1:max_index);
        trace_future = trace2((length(trace1) - max_index + 1):length(trace1));
        valid_elements = trace_present > -1 & trace_future > -1;
        trace_present = trace_present(valid_elements);
        trace_future = trace_future(valid_elements);
        output(tau_index) = sum((trace_present - mean_value(1)) .* (trace_future - mean_value(2)))/(length(trace_present) - 1) / (sqrt(var_value(1))*sqrt(var_value(2)));
    end
end