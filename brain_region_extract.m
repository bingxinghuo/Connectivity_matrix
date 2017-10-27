%% extrregiont auditory cortex from Hashikawa atlas
% get reference list
load('regionlist_v4.mat', 'part_label_list')
regionmatchidx=strfind(lower(part_label_list(:,3)),'auditory');
regionmatchidx=find(~(cellfun('isempty',regionmatchidx)));
regionids=cell2mat(part_label_list(regionmatchidx,4));
% get (deformed) Hashikawa atlas
hashi_isotropic=load_nii('annotation_80_flip.nii');
hashiimg=hashi_isotropic.img;
regionsec=zeros(size(hashiimg,2),1);
for i=1:size(hashiimg,2)
    isregion=intersect(squeeze(hashiimg(:,i,:)),regionids);
    regionsec(i)=~isempty(isregion);
end
regionsecid=find(regionsec);