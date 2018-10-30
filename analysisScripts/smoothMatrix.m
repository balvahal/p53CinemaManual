function matrix = smoothMatrix(matrix, span, method)
    for i=1:size(matrix,1)
        if(strcmp(method, 'median'))
            trace = medfilt1(matrix(i,matrix(i,:) ~= -1), span);
        else
            trace = smooth(matrix(i,matrix(i,:) ~= -1), span, method);
        end
        matrix(i,matrix(i,:) ~= -1) = trace;
    end
end