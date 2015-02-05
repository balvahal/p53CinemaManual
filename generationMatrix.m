function [generationMatrix, indexes] = generationMatrix(divisionMatrix)
generationMatrix = zeros(size(divisionMatrix));
indexes = 1:size(divisionMatrix,1);

divisionTiming = getDivisionTiming(divisionMatrix);
[~,ordering] = sort(divisionTiming(:,1));
divisionMatrix = divisionMatrix(ordering,:);
indexes = indexes(ordering);

[~,ordering] = sort(sum(divisionMatrix,2));
divisionMatrix = divisionMatrix(ordering,:);
indexes = indexes(ordering);

for i=1:size(divisionMatrix,1)
    divisionEvents = find(divisionMatrix(i,:) == 1);
    for j=1:length(divisionEvents)
        d = divisionEvents(j);
        generationMatrix(i, d:end) = generationMatrix(i, d:end) + 1;
    end
end

end