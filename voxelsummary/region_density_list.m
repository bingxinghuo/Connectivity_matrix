function [idsorted,densitysorted,regionsorted]=region_density_list(neurondensity,annoimg,regionLUT)
[H1,W1,~]=size(annoimg);
annolist=unique(nonzeros(annoimg)); % 
regiondensity=zeros(length(annolist),2);
for n=1:length(annolist)
    annomask=annoimg==annolist(n); % one volumetric mask for each region
    voxdensity=annomask.*neurondensity(1:H1,1:W1,:); % extract projection density
    regiondensity(n,:)=[annolist(n),nanmean(nonzeros(voxdensity))]; % average projection density
end
% sort the output
[densitysorted,isort]=sort(regiondensity(:,2),'descend');
isort=isort(~isnan(densitysorted));
densitysorted=densitysorted(~isnan(densitysorted));
idsorted=regiondensity(isort,1);
% read out the region annotation when available
if nargin>2
    mouselistid=cell2mat(regionLUT(:,4));
    regionsorted=cell(length(idsorted),2);
    for i=1:length(idsorted)
        ind=find(mouselistid==idsorted(i));
        if ~isempty(ind)
            regionsorted(i,:)=regionLUT(ind,2:3);
        end
    end
else
    regionsorted=[];
end

