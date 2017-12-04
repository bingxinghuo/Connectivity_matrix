% a routine of checking brain region id in registered Hashikawa atlas
m920anno=load_nii('M920_annotation.img');
[fileind,~]=jp2ind(filelist,'440');
figure, imagesc(squeeze(m920anno.img(:,365-fileind+1,:)))
caxis([0 600])
axis xy
% inspect the signal area ID
ids=cell2mat(Fulllist(:,4));
idx=find(ids==150);
Fulllist{idx,2:3}