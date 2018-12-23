function idx = findpattern_once(in_array, pattern)
%FINDPATTERN  Find a pattern in an array.
%
%    K = FINDPATTERN(ARRAY, PATTERN) returns the starting indices
%    of any occurences of the PATTERN in the ARRAY.  ARRAY and PATTERN
%    can be any mixture of character and numeric types.
%
%    Examples:
%        a = [0 1 4 9 16 4 9];
%        b = double('The year is 2003.');
%        findpattern(a, [4 9])         returns [3 6]
%        findpattern(a, [9 4])         returns []
%        findpattern(b, '2003')        returns 13
%        findpattern(b, uint8('2003')) returns 13
%
%    See also STRFIND, STRCMP, STRNCMP, STRMATCH.

% Algorithm:
% Find all of the occurrences of each number of the pattern.
%
% For an n element pattern, the result is an n element cell array.  The
% i-th cell contains the positions in the input array that match the i-th
% element of the pattern.
%
% When the pattern exists in the input stream, there will be a sequence
% of consecutive integers in consecutive cells.

% As currently implemented, this routine has poor performance for patterns
% with more than half a dozen elements where the first element in the
% pattern matches many positions in the array.

if(numel(pattern) == 1)
    idx = find(in_array == pattern, 1, 'first');
    return;
end

locations = cell(1, numel(pattern));
for p = 1:(numel(pattern))
    locations{p} = find(in_array == pattern(p));
end

% Find instances of the pattern in the array.
idx = [];
for p = 1:numel(locations{1})
    
    % Look for a consecutive progression of locations.
    start_value = locations{1}(p);
    for q = 2:numel(locations)
        
        found = true;
        
        if (~any((start_value + q - 1) == locations{q}))
            found = false;
            break;
        end
        
    end
    
    if (found)
        idx(end + 1) = locations{1}(p);
        break;
    end
    
end