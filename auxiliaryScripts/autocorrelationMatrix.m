function acmatric = autocorrelationMatrix(matrix, tau_range)
acmatric = zeros(size(matrix, 1), length(tau_range));
for i=1:size(matrix,1)
    currentTrace = matrix(i,:);
    trimmedTrace = currentTrace(find(currentTrace > -1, 1, 'first'):find(currentTrace > -1, 1, 'last'));
    acmatric(i,:) = autocorrelation(trimmedTrace, tau_range);
end
end