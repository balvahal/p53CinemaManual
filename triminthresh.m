function [threshold,n,xout,n2,xout2] = triminthresh(A)
%Calculate a few rank statistics (assumes A is already sorted)
la = length(A);
q1a = A(round(0.25*la)); %first quartile
q2a = A(round(0.50*la));
q3a = A(round(0.75*la)); %third quartile
myIQRa = q3a-q1a;
myCutoffa = 3*myIQRa+q2a;
%Create the histogram
[n,xout]=hist(A,50);
%Use the triangle threshold for the initial guess
ind = triangleThreshCore(n);
threshold = xout(ind);
%Look for minimum change in the number of foci or when the change in foci
%is less than 1.
B = A(A>threshold);
[n2,xout2] = hist(B,50);
n2der = smooth(n2);
n2der = conv(n2der,[0.5 0 -0.5],'same'); %the central difference derivative to find the min
for i = 2:length(n2der);
    if (n2der(i-1)<0 && n2der(i)>=0)
        ind = i-1;
        break
    elseif (abs(n2der(i-1))<=1) && (n2(i-1) == 0 || n2(i-1) == 1 || n2(i-1) == 2)
        ind = i-1;
        break
    end
end
threshold = xout2(ind);

end