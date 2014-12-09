uniqueGroups = unique(database.group_label);
for g=1:length(uniqueGroups)
    currentGroup = uniqueGroups{g};
    fprintf('%s\n', currentGroup);
    uniquePositions = sort(unique(database.position_number(strcmp(database.group_label, uniqueGroups{g}))));
    for i=1:4:length(uniquePositions)
        mergeGridPosition_blind(database, '.\RAW_DATA_UNMERGED', '.\RAW_DATA', currentGroup, uniquePositions(i + [0,1,3,2]), {'CFP', 'YFP'}, '');
    end
end