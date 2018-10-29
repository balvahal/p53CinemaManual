function divisionTiming = getDivisionTiming(divisionMatrix)
maxDivisions = max(nansum(divisionMatrix,2));
divisionTiming = NaN * ones(size(divisionMatrix,1), maxDivisions);
for j=1:size(divisionMatrix,1)
    divisionEvents = find(divisionMatrix(j,:) > 0);
    if(~isempty(divisionEvents))
        divisionTiming(j,1:length(divisionEvents)) = divisionEvents;
    end
end
end