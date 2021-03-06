function [] = plotFSfig(fs1,fs2,nFeatures,featList)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

X = zeros(nFeatures,3);
X(fs1,1) = 1;
X(fs2,2) = 1;
X(:,3) = sum(X(:,1:2),2);

figure
imagesc(X)
set(gca, 'XTick', 1:3, 'XTickLabel', ...
    {'Kruskal-Wallis','Fisher Score','TOTAL'},...
    'YTick',1:nFeatures,'YTickLabel',featList);

% Create a discrete colormap
cmap=parula(3);
colormap(cmap([1 2 3],:))
h=colorbar;
% Set tick marks to be middle of each range
dTk = diff(h.Limits)/(2*length(cmap));
set(h,'Ticks',[h.Limits(1)+dTk:2*dTk:h.Limits(2)-dTk],'TickLabels',0:2)

end

