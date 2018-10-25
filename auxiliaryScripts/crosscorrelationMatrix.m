function xcorr_matrix = crosscorrelationMatrix(traces1, traces2, tau_range)
% xcorr_matrix = zeros(size(traces1,1), 2*maxLag + 1);
% for i=1:size(traces1,1)
%     y = xcorr(traces2(i, :), traces1(i, :), maxLag, 'coeff');
%     xcorr_matrix(i,:) = y;
% end
% xcorr_matrix = xcorr_matrix(:,maxLag:end);

xcorr_matrix = zeros(size(traces1, 1), length(tau_range));
minLength = min(size(traces1,2), size(traces2,2));
traces1 = traces1(:,1:minLength);
traces2 = traces2(:,1:minLength);
for i=1:size(traces1,1)
    currentTrace1 = traces1(i,:);
    currentTrace2 = traces2(i,:);
    trimTimepoints(1) = max(find(currentTrace1 > -1, 1, 'first'), find(currentTrace2 > -1, 1, 'first'));
    trimTimepoints(2) = min(find(currentTrace1 > -1, 1, 'last'), find(currentTrace2 > -1, 1, 'last'));
    xcorr_matrix(i,:) = crosscorrelation(currentTrace1(trimTimepoints(1):trimTimepoints(2)), currentTrace2(trimTimepoints(1):trimTimepoints(2)), tau_range);
end
end