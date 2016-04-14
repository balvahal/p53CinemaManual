function [] = plotSingleCellFamily_plotyy(timepoints, traces1, traces2, divisions, lineageTree, progenitorCell)
%traces2 = log(traces2);

familyMembers = find(lineageTree(:,1) == progenitorCell);
subTraces1 = traces1(familyMembers,:);
subTraces2 = traces2(familyMembers,:);
subDivisions = divisions(familyMembers,:);
subTree = lineageTree(familyMembers,:);

blue = [3,126,199]/255;
red = [230, 91, 98]/255;
green = [0, 162, 37] / 255;

% Limits based on traces from a single family
ylim1 = [min(subTraces1(:)), max(subTraces1(:)) * 0.9];
ylim2 = [min(subTraces2(:)), max(subTraces2(:)) * 0.9];
% Limits based on traces from the whole dataset
ylim1 = [min(traces1(:)), max(traces1(:)) * 0.9];
ylim2 = [min(traces2(:)), max(traces2(:)) * 0.9];

xlimits = [min(timepoints), max(timepoints)];
color2 = red;
color1 = green;

%temp plots for getting axes properties
f = figure; plot(timepoints, subTraces1(1,:)); ylim(ylim1);
ytickmarks1 = get(gca, 'YTick'); delete(f);
f = figure; plot(timepoints, subTraces2(1,:)); ylim(ylim2);
ytickmarks2 = get(gca, 'YTick'); delete(f);

f = figure; set(gcf, 'Color', 'w');
p = panel();
p.pack('h', {1/4, []});
p(2).pack(length(familyMembers), 1);
p.de.margin = 1;
p.margin = [2, 10, 10, 2];
p(2).margin = [10,2,2,2];

dist = pDist_lastCommonAncestor(subTree);
p(1).select();
[H,~,outperm] = dendrogram(linkage(dist), 'Orientation', 'left');
set(H, 'Color', [0.4, 0.4, 0.4], 'LineWidth', 1.5);
set(gca, 'xtick', [], 'ytick', [], 'ylim', [0.5, length(familyMembers) + 0.5], 'XColor', [1,1,1], 'YColor', [1,1,1]);

outperm = fliplr(outperm);

for j=1:length(familyMembers)
    p(2,j,1).select();
    
    % Plot yy
    [hAx,hLine1,hLine2] = plotyy(timepoints, subTraces1(outperm(j),:), timepoints, subTraces2(outperm(j),:));
    set(hLine1, 'color', color1);
    set(hLine2, 'color', color2);
    set(hAx(1), 'ylim', ylim1, 'YTick', ytickmarks1, 'XLim', xlimits, 'ycolor', color1);
    set(hAx(2), 'ylim', ylim2, 'YTick', ytickmarks2, 'XTick', [], 'Xlim', xlimits, 'ycolor', color2);
    hold all;
    
    % Add a line
    plot([127, 127]/6, ylim, 'color', [0.6, 0.6, 0.6]);
    
    % Plot division events
    divisionEvents = find(subDivisions(outperm(j),:));
    plot(timepoints(divisionEvents), subTraces1(outperm(j),divisionEvents), 'p', 'MarkerFaceColor', [0.9, 0.9, 0], 'Color', [0,0,0]);
    %ylim(ylimit);
    if(j < length(familyMembers))
        set(gca, 'xtick', []);
    end
    set(gca, 'FontSize', 8);
    %p(j,1).ylabel('p53 level (a.u.)');
end
p(2,j,1).xlabel('Time post-irradiation (h)');
end