function divisionIds = getDivisionId(divisionMatrix, cell_ids)
maxDivisions = max(sum(divisionMatrix,2));
divisionIds = zeros(size(divisionMatrix,1), maxDivisions);
for j=1:size(divisionMatrix,1)
    divisionEvents = find(divisionMatrix(j,:) > 0);
    if(~isempty(divisionEvents))
        divisionIds(j,1:length(divisionEvents)) = cell_ids(j,divisionEvents);
    end
end
end