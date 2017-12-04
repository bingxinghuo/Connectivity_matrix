function [region3d,totalpix]=regionread(atlas3d,regionid)
region3d=zeros(size(atlas3d));
% region3d=cast(region3d,'like',atlas3d);
regionid=cast(regionid,'like',atlas3d);
tic
for i=1:length(regionid)
    region3d=region3d+(atlas3d==regionid(i));
end
toc    
totalpix=sum(sum(sum(region3d)));