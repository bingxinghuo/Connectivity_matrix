%% volsurfproj_vis.m
% This script visualize the multi-polygons obtained from volsurfproj.m
% Inputs:
%   - volsurf: output from volsurfproj.m. a Nx1 cell, each containing a Mx1 cells of all polygons
%   associated with one region ID.
%   - h: optional. an axis handle to plot on.
%   - ifhsv: optional. If set to nonzero number, switch to HSV colormap rather than the default. 
% Output:
%   - volsurfpoly: a Nx1 cell, each containing a multi-polygon for one
%   region ID.
function volsurfpoly=volsurfproj_vis(volsurf,h,ifhsv)
% axis handle
if nargin<2
    figure; h=gca;
end
hold(h,'on')
% initiate 
volsurfpoly=cell(size(volsurf,1),1);
warning off
% set color map
colors=lines(length(volsurf));
if nargin>2
    if ifhsv~=0
        colors=hsv(length(volsurf));
    end
end
for i=1:length(volsurf) % each cell is associated with one region ID
    if ~isempty(volsurf{i})
        % combine all polygons for each region ID
        volsurf1=volsurf{i};
        ind=cellfun(@isempty,volsurf1);
        volsurf1=volsurf1(~ind);
        polyvec=cat(2,[volsurf1{:}]);
        polyu=union(polyvec);
        plot(polyu,'edgecolor','none','facecolor',colors(i,:)) % plot
        volsurfpoly{i}=polyu; % save
    end
end
axis image
alpha 1 % setting to 1 for proper saving into espc later
warning on