function [validStrings, dictionary] = getTokenDictionary(stringSet, expression)
    dictionary = regexp(stringSet, expression, 'tokens', 'once');
    validStrings = ~cellfun(@isempty, dictionary);
    dictionary = vertcat(dictionary{:});
end