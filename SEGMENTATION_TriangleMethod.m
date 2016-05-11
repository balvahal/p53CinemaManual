%% cellularGPS_TriangleMethod
% a threhold method that works particularly well when the image consists of
% mostly background and a foreground, or a large peak (background) and a
% long tail (foreground).
%
%   [trithresh] = cellularGPS_TriangleMethod(I)
%
%%% Input
% * I: A grayscale image.
%
%%% Output:
% * trithresh: the threshold value determined from the image.
%
%%% Detailed Description
% There is no detailed description.
%
%%% Other Notes
% 
function [trithresh] = cellularGPS_TriangleMethod(I, outlierQuantile)
%% Approximate histogram as triangle
%%%
% Create the histogram
A=double(reshape(I,[],1));
A = A(A <= quantile(A, outlierQuantile));
[n,xout]=hist(A,100);
%%%
% Find the highest peak the histogram
[c,ind]=max(n);
%%%
% Assume the long tail is to the right of the peak and envision a line from
% the top of this peak to the end of the histogram.
% The slope of this line, the hypotenuse, is calculated.
x1=0;
y1=c;
x2=length(n)-ind;
y2=n(end);
m=(y2-y1)/(x2-x1); %The slope of the line

%% Find the greatest distance
% We are looking for the greatest distance betweent the histrogram and line
% of the triangle via perpendicular lines The slope of all lines
% perpendicular to the histogram hypotenuse is the negative reciprocal
p=-1/m; %The slope is now the negative reciprocal
%%%
% We now have two slopes and two points for two lines. We now need to solve
% this two-equation system to find their intersection, which can then be
% used to calculate the distances
iarray=(0:(length(n)-ind));
L=zeros(size(n));
for i=iarray
intersect=(1/(m-p))*[-p,m;-1,1]*[c;n(i+ind)-p*i]; %intersect(1)= y coordinate, intersect(2)= x coordinate
L(i+ind)=sqrt((intersect(2)-i)^2+(intersect(1)-n(i+ind))^2);
end
[~,ind2]=max(L);
trithresh=xout(ind2);
end