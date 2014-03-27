function [ varianceImage ] = varianceFilter( Image, windowSize )
%VarianceFilterFunction = @(x) var(x(:));
%varianceImage = nlfilter(Image, [windowSize windowSize], VarianceFilterFunction);
varianceImage = reshape(std(im2col(Image,[windowSize windowSize],'sliding')), ...
    size(Image)-windowSize+1); 
end

