%% This script aims at finding new injection additions to the brainarchitecture.org
% import 3 columns from the Excel file: Tracer, Region, and Brain ID
% original data imported as marmosetinjections
% new data imported as Rosawebnow
%% combine these 3 information as one string as the unique identifier for the injection
Lnew=size(Rosawebnow,1);
for i=1:Lnew
rosawebnow1{i}=cell2mat(Rosawebnow(i,1:3));
end
marm1=cellfun(@num2str,marmosetinjections(:,1:3),'UniformOutput',false); % convert numbers to strings
Lold=size(marm1,1);
for i=1:Lold
marminj1{i}=cell2mat(marm1(i,1:3));
end
% compare
for i=1:140
rosacomp(i)=ismember(rosawebnow1(i),marminj1);
end
Lnew-sum(rosacomp) % 29 new additions
newind=find(rosacomp==0); % row index of the new additions
Rosawebnow(newind,:) % show all the information of the new injection