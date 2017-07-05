function [generationMatrix, indexes] = generationMatrix_withTimeThreshold(divisionMatrix, timeThreshold)
generationMatrix = zeros(size(divisionMatrix));
indexes = 1:size(divisionMatrix,1);

divisionTiming = getDivisionTiming(divisionMatrix(:,timeThreshold:end));
[~,ordering] = sort(divisionTiming(:,1));
divisionMatrix = divisionMatrix(ordering,:);
indexes = indexes(ordering);

[~,ordering] = sort(sum(divisionMatrix(:,timeThreshold:end),2));
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