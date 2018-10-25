function d = pDist_lastCommonAncestor(M)
d = zeros(size(M,1),size(M,1)) * size(M,2);
for i=1:size(M,1)
    x1 = M(i,:);
    for j=(i+1):size(M,1)
        x2 = M(j,:);
        validPoints = find(x1 > 0 & x2 > 0);
        distance = validPoints(find(x1(validPoints) == x2(validPoints), 1, 'last'));
        d(i,j) = length(x1) - distance + 1;
        d(j,i) = length(x1) - distance + 1;
    end
end
end