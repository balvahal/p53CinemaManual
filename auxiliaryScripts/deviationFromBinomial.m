function deviation = deviationFromBinomial(x)
if(length(x) < 2)
    deviation = ones(3,1);
else
    nBootstrap = 30;
    results = NaN * ones(nBootstrap, 1);
    for i=1:nBootstrap
        v = randsample(x, length(x), 1);
        p = (sum(v == 1)/2 + sum(v == 2))/length(v);
        expected = [p^2, 2*p*(1-p), (1-p)^2] * length(v);
        observed = [sum(v==2), sum(v==1)/2, sum(v==0)];
        results(i) = log(chi2cdf(sum((observed-expected).^2./expected), length(observed), 'upper'));
        %[~,deviation] = chi2gof(observed, 'Expected', expected);
        %results(i) = deviation;
    end
    deviation(1) = nanmedian(results);
    deviation(2:3) = quantile(results(~isnan(results)), [0.25, 0.75]);
    deviation(2) = deviation(1) - deviation(2);
    deviation(3) = deviation(3) - deviation(1);
    deviation = deviation';
end
end

% function deviation = deviationFromBinomial(v)
% p = (sum(v == 1) + 2*sum(v == 2))/(2*length(v));
% expected = [p^2, 2*p*(1-p), (1-p)^2];
% observed = [sum(v==0), sum(v==1)/2, sum(v==2)]/length(v);
% [~,deviation] = chi2gof(observed, 'Expected', expected);
% end