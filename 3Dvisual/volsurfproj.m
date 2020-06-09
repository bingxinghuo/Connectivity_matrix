%% volsurfproj.m
% This script projects the volume to the surface of a certain orientation
% Inputs:
%   - volimg: a volumetric image where the entries represents region IDs
%   - direction: the direction to project the surface to
%   - regionids: optional. Specific region IDs to be extracted. If left
%   blank, take all available region IDs in the volume. Nx1.
% Outputs:
%   - regionsurf: a Nx1 cell, each containing a Mx1 cells of all polygons
%   associated with one region ID. 
%   - surfmask: a 2D projection of the volume surface in the specified
%   direction
function [regionsurf,surfmask]=volsurfproj(volimg,direction,regionids)
% set region IDs
if nargin>2
    annoregion=cell(3,1);
    annoregionall=zeros(size(volimg));
    R=length(regionids);
    for i=1:R
        %     regioncolor{i}=treedata{regionids(i)}.color;
        annoregion{i}=volimg==regionids(i);
        annoregionall=annoregionall+annoregion{i}*regionids(i);
    end
else
    annoregionall=volimg;
    regionids=unique(nonzeros(volimg));
end
%%
warning off
[D1,D2,D3]=size(annoregionall);
if direction==2
    D3surf=zeros(D1,D3);
    for z=1:D2
        D3=double(squeeze(annoregionall(:,D2-z+1,:)));
        %         D3=double(squeeze(annoregionall(:,z,:)));
        D3surf=D3surf+D3-(D3>0&D3surf>0).*D3surf;
    end
    if nargout>1
        surfmask=D3surf;
    end
    %     D3surf=flip(D3surf,1);
    regionsurf=improject(D3surf,regionids);
elseif direction==3
    D2surf=zeros(D1,D2);
    for w=round(D3/2):D3
        D2=double(squeeze(annoregionall(:,:,w)));
        D2surf=D2surf+D2-(D2>0&D2surf>0).*D2surf;
    end
    D2surf=flip(D2surf,1);
    D2surf=flip(D2surf,2);
    if nargout>1
        surfmask=D2surf;
    end
    regionsurf=improject(D2surf,regionids);
elseif direction==1
    D1surf=zeros(D2,D3);
    for h=round(D1/2):D1
        D1=double(squeeze(annoregionall(h,:,:)));
        D1surf=D1surf+D1-(D1>0&D1surf>0).*D1surf;
    end
    D1surf=imrotate(D1surf,-90);
    if nargout>1
        surfmask=D1surf;
    end
    regionsurf=improject(D1surf,regionids);
end
warning on
end

%%%%%%%%% This function converts the surface mask in to polygon vectors
function regionproj=improject(imgsurf,regionids)
R=length(regionids);
imgedge=cell(R,1);
regionproj=cell(R,1);
for i=1:R
    imgedge{i}=bwboundaries(imgsurf==regionids(i));
    for k=1:length(imgedge{i})
        if size(imgedge{i}{k},1)>2
            regionproj{i}{k}=polyshape(imgedge{i}{k});
        end
    end
end
end