function regionpoly=regioncontour(bwimg)
regionoutline=bwboundaries(bwimg);
regionN=size(regionoutline,1);
regionpoly=cell(regionN,1);
for j=1:regionN
    k1=length(unique(regionoutline{j}(:,1)));
    k2=length(unique(regionoutline{j}(:,2)));
    k=min(k1,k2);
    if k>1
        regionpoly{j}=polyshape(regionoutline{j}(:,1),regionoutline{j}(:,2));
    end
end