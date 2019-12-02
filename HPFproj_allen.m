% load('Allenmatchtable.mat', 'AllenConnMatregions')
toplevelind=[3];
regind=[];
for l=1:length(toplevelind)
regind=[regind;find(M1commonmat.marmoset(:,2)==toplevelind(l))]; % thalamus high level index 
end
regid=M1ant.common(regind,1); % this could contain only partial of the volume
% e.g. ENTl is not further subdivided in Allen's connectivity matrix
%%
regleafid=cell(length(regid),3);
for i=1:length(regid)
    childsid=[];
    for l=1:length(regid{i})
        childs=childreninfo(mouselist,regid{i}(l),0);
        childsid=[childsid;cell2mat(childs(:,4))];
        regleafid{i,1}=childsid;
    end
end
% MOefftargets=regleafid{1};
MOefftargets=cell(size(regleafid,1),3);
MOefftargets(:,1)=regleafid(:,1);
eff_ipsi_perc=eff_ipsi./(ones(size(eff_ipsi,1),1)*sum([eff_ipsi;eff_contra]));
eff_contra_perc=eff_contra./(ones(size(eff_ipsi,1),1)*sum([eff_ipsi;eff_contra]));
for i=1:size(MOefftargets,1)
    MOefftargets{i,2}=0;
    MOefftargets{i,3}=0;
    for j=1:length(MOefftargets{i})
        ind=find(cell2mat(AllenConnMatregions(:,3))==MOefftargets{i,1}(j));
        if ~isempty(ind)
            MOefftargets{i,2}=MOefftargets{i,2}+eff_ipsi_perc(ind,1)+eff_contra_perc(ind,1);
            MOefftargets{i,3}=MOefftargets{i,3}+eff_ipsi_perc(ind,2)+eff_contra_perc(ind,2);
        end
    end
end
%% This will include everything within a specified region, but may not be matched with MBA data
topregions=find(cell2mat(Allenmatch(:,2))==toplevelind);
hpfeff(:,2)=eff_contra_perc(topregions,1)+eff_ipsi_perc(topregions,1);
hpfeff(:,3)=eff_contra_perc(topregions,2)+eff_ipsi_perc(topregions,2);