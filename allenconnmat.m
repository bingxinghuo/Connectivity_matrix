for i=1:size(AllenConnMatregions,1)
    ind=find(strcmp(mouselist(:,2),AllenConnMatregions{i}));
%     if length(ind)>1
%         [~,indm]=min(cell2mat(mouselist(ind,1)));
%     end
%     AllenConnMatregions(i,2)=mouselist(ind,4);
    regionlineage=lineageinfo(mouselist,mouselist{ind,4},0);
    AllenConnMatregions(i,2:2+size(regionlineage,1)-1)=flip(regionlineage(:,4)');
end
%% 
parentind=cell2mat(parentlist(:,4));
regionparentsort=zeros(size(AllenConnMatregions,1),1);
for i=1:length(parentind)
    for j=1:size(AllenConnMatregions,1)
        if sum(cell2mat(AllenConnMatregions(j,2:end))==parentind(i))>0
            regionparentsort(j)=i;
        end
    end
end
[parentsort,regionsorti]=sort(regionparentsort);
%%
effall=eff_contra'+eff_ipsi';
% [parentsort,regionsorti]=sort(cell2mat(AllenConnMatregions(:,3)),'ascend');
effallsort=effall(regionsorti,:);
P=unique(parentsort);
parentinfo=cell(length(P),3);
for i=1:length(P)
    pind=find(cell2mat(AllenConnMatregions(:,3))==P(i));
    effparent(i,:)=sum(effall(pind,:));
    parentinfo{i,1}=P(i);
    ind=find(cell2mat(mouselist(:,4))==P(i));
    parentinfo(i,2:3)=mouselist(ind,2:3);
end
%%
affall=aff_contra+aff_ipsi;
[parentsort,regionsorti]=sort(cell2mat(AllenConnMatregions(:,3)),'ascend');
affallsort=affall(regionsorti,:);
%%
affave=zeros(length(regions),2);
for i=1:length(regions)
    regioni=find(strcmp(affraw(:,1),regions{i}));
    if ~isempty(regioni)
    regioni1(i)=regioni(1);
    affave(i,:)=mean(cell2mat(affraw(regioni,4:5)));
    end
end
[~,regionsorti]=sort(regioni1,'ascend');
affave=affave(regionsorti,:);
%%
effraw=effraw';
effave(:,1)=mean(effraw(:,1:10),2);
effave(:,2)=mean(effraw(:,11:16),2);
effave=effave(1:296,:)+effave(297:end,:);
%% names
regionsort=regions(regionsorti);
regionnamei=zeros(1,size(regionname,2));
k=1;
for i=1:size(regionname,2)
if ~isempty(regionname{1,i})
k=k+1;
regionnamei(i)=k;
else
regionnamei(i)=k;
end
end
regionnamei=regionnamei(1:296);