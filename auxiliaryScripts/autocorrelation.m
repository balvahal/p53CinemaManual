function output = autocorrelation(trace, range)
    output = zeros(length(range), 1);
    valid_elements = trace > -1;
    mean_value = mean(trace(valid_elements));
    var_value = var(trace(valid_elements));
    for tau_index = 1:length(range)
        tau = range(tau_index);
        max_index = length(trace) - tau;
        trace_present = trace(1:max_index);
        trace_future = trace((length(trace) - max_index + 1):length(trace));
        valid_elements = trace_present > -1 & trace_future > -1;
        trace_present = trace_present(valid_elements);
        trace_future = trace_future(valid_elements);
        output(tau_index) = sum((trace_present - mean_value) .* (trace_future - mean_value))/(length(trace_present) - 1) / var_value;
    end
end