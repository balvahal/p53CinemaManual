function permutations = permutation_withReplacement(x, level)
    if(isrow(x))
        x = x';
    end
    if(level == 1)
        permutations = x;
    else
        temp = permutation_withReplacement(x, level-1);
        permutations = repmat(temp, length(x), 1);
        permutations = horzcat(permutations, sort(repmat(x, size(temp,1), 1)));
    end
end