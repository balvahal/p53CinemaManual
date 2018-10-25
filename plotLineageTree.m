function [] = plotLineageTree(divisions, lineageTree, progenitorCell)
familyMembers = find(lineageTree(:,1) == progenitorCell);
subDivisions = divisions(familyMembers,:);
subTree = lineageTree(familyMembers,:);
dist = pDist_lastCommonAncestor(subTree);
[H,~,outperm] = dendrogram(linkage(dist, 'single'), 'Orientation', 'left', 'labels', num2str(sum(subDivisions,2)));
set(H, 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.5);
set(gca, 'xtick', [], 'ylim', [0.5, length(familyMembers) + 0.5], 'XColor', [1,1,1]);
end