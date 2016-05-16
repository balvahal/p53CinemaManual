function [] = plotSingleCellFamily(timepoints, traces1, divisions, lineageTree, progenitorCell)
familyMembers = find(lineageTree(:,1) == progenitorCell);
subTraces1 = traces1(familyMembers,:);
subDivisions = divisions(familyMembers,:);
subTree = lineageTree(familyMembers,:);

timepoints = 1:size(subTraces1,2);
ylimit = [min(150, min(subTraces1(:))), max(500,max(subTraces1(:)) * 1.05)];

p = panel();
p.pack('h', {1/4, []});
p(2).pack(length(familyMembers), 1);
p.de.margin = 1;
p.margin = [2, 10, 2, 2];
p(2).margin = [10,2,2,2];
set(gcf, 'Color', 'w');

dist = pDist_lastCommonAncestor(subTree);
p(1).select();
[H,~,outperm] = dendrogram(linkage(dist), 'Orientation', 'left');
set(H, 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.5);
set(gca, 'xtick', [], 'ytick', [], 'ylim', [0.5, length(familyMembers) + 0.5], 'XColor', [1,1,1], 'YColor', [1,1,1]);

outperm = fliplr(outperm);

for j=1:length(familyMembers)
    p(2,j,1).select();
    plot(timepoints, subTraces1(outperm(j),:), 'Color', [0.2, 0.65, 0.1]);
    divisionEvents = find(subDivisions(outperm(j),:));
    hold all;
    plot(timepoints(divisionEvents), subTraces1(outperm(j),divisionEvents), 'p', 'MarkerFaceColor', [0.9, 0.9, 0], 'Color', [0,0,0]);
    ylim(ylimit);
    if(j < length(familyMembers))
        set(gca, 'xtick', []);
    end
    set(gca, 'FontSize', 8);
    %p(j,1).ylabel('p53 level (a.u.)');
end
p(2,j,1).xlabel('Time post-irradiation (h)');
end