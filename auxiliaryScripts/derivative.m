function derv = derivative(trajectoryMatrix)
    rightside = trajectoryMatrix(:,2:end-1) - trajectoryMatrix(:,1:end-2);
    leftside = trajectoryMatrix(:,3:end) - trajectoryMatrix(:,2:end-1);
    derv = (rightside + leftside) / 2;
    %derv = leftside;
end