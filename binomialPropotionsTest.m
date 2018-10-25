function [p, z] = binomialPropotionsTest(p1, p2, n1, n2)
    p_hat = (p1*n1 + p2*n2) / (n1+n2);
    z = (p1-p2) / sqrt(p_hat * (1-p_hat) / (n1+n2));
    p = normcdf(z, 'upper');
end