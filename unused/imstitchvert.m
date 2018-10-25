function [c2, c1, outputImage] = imstitchvert(IM2, IM1)
% IM1 will be stitched on the bottom of IM2
expectedOverlap = 10;
trimming = 10;

subIM2 = IM2(end-expectedOverlap:end,trimming:end-trimming);
cc = normxcorr2(subIM2, IM1);
[~, mi] = max(cc(:));
[j,i] = ind2sub(size(cc), mi);
xoffset = i - size(IM1,2) + trimming;
targetWidth = min(size(IM1,2) - abs(xoffset), size(IM2,2) - abs(xoffset));

if(xoffset < 0)
    c2 = [1, (abs(xoffset)+1), size(IM2,1) - j + 1, targetWidth];
    c1 = [1,1,size(IM1,1),targetWidth];
else
    c2 = [1, 1, size(IM2,1) - j + 1, targetWidth];
    c1 = [1, (abs(xoffset)+1), size(IM1,1), targetWidth];
end
newIM2 = IM2(c2(1):(c2(1)+c2(3)-1),c2(2):(c2(2)+c2(4)-1));
newIM1 = IM1(c1(1):(c1(1)+c1(3)-1),c1(2):(c1(2)+c1(4)-1));
outputImage = vertcat(newIM2, newIM1);
end