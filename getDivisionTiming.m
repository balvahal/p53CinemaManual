function divisionTiming = getDivisionTiming(divisionMatrix)
maxDivisions = max(sum(divisionMatrix,2));
divisionTiming = zeros(size(divisionMatrix,1), maxDivisions);
for j=1:size(divisionMatrix,1)
    divisionEvents = find(divisionMatrix(j,:));
    if(~isempty(divisionEvents))
        divisionTiming(j,1:length(divisionEvents)) = divisionEvents;
    end
end
end