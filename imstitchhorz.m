function [c1, c2, outputImage] = imstitchhorz(IM1, IM2)
% % IM2 will be stitched on the right of IM1
% expectedOverlap = 70;
% trimming = 10;
% 
% subIM1 = IM1(trimming:(end-trimming),end-expectedOverlap:end);
% cc = normxcorr2(subIM1, IM2);
% [mp, mi] = max(cc(:));
% [j,i] = ind2sub(size(cc), mi);
% yoffset = j - size(IM1,1) + trimming;
% targetHeight = min(size(IM1,1) - abs(yoffset), size(IM2,1) - abs(yoffset));
% 
% newIM2 = IM2((abs(yoffset)+1):abs(yoffset)+targetHeight,i:end);
% newIM1 = IM1(1:targetHeight,:);
% outputImage = horzcat(newIM1, newIM2);
% 
% c2 = [(abs(yoffset)+1), i, targetHeight, size(IM2,2) - i +1];
% c1 = [1, 1, targetHeight, size(IM1,2)];

IM1 = IM1';
IM2 = IM2';
[c1, c2, outputImage] = imstitchvert(IM1, IM2);
c1 = c1([2,1,4,3]);
c2 = c2([2,1,4,3]);
outputImage = outputImage';

end