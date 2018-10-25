function lastDivision = getLastDivision(divisions)
    lastDivision = zeros(size(divisions,1),1);
    for i=1:size(divisions,1)
        currentTiming = find(divisions(i,:) == 1, 1, 'last');
        if(~isempty(currentTiming))
            lastDivision(i) = currentTiming;
        end
    end
end