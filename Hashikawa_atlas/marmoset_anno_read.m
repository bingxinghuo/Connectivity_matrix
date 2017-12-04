%% 1. extract the leaf in the tree structure
% adopted same routine as braintree_part.m
%%
load regionlist % output from braintree.m
%%
partid=brainlayers(Fulllist);
N1=size(partid,1); % number of top tier structures
L=max([Fulllist{:,1}]); % number of layers in the hierarchy
%% extract all brain structures
[N1,layers]=size(partid(:,2:end));
allbranches=cell(N1,layers);
allbranches_abb=cell(N1,layers);
for n=1:N1
    for l=1:layers
        regionids=partid{n,l+1};
        regioninds=zeros(length(regionids),1);
        for r=1:length(regionids)
        regioninds(r)=find([Fulllist{:,4}]==regionids(r));
        end
    allbranches{n,l}=Fulllist(regioninds,3);
    allbranches_abb{n,l}=Fulllist(regioninds,2);
    end
end
%% Consolidate all the sub-structures under each layer 1 structures
partid_all=[partid(:,1),cell(N1,2)];
% 1. Column 2 contains the brain part id (in one row)
for i=1:N1 % separates according to brain parts at layer 1
    partid_all{i,2}=[];
    for j=1:L % go over each layer
        if ~isempty(partid{i,j+1})
        partid_all{i,2}=[partid_all{i,2};partid{i,j+1}(:,1)]; 
        end
    end
end
% 2. Column 3 contains the index of those brain parts in Fulllist
for i=1:N1
    Nparts=length(partid_all{i,2});
    partind=zeros(1,Nparts);
    for j=1:Nparts
        partind(j)=find([Fulllist{:,4}]==partid_all{i,2}(j));
    end
    partid_all{i,3}=partind;
end
%% 2. read out brain regions from the atlas
marmo=load_nii('LabelMap.nii');
marmo.atlas=marmo.img;
marmo.atlas(678/2+1:678,:,:)=marmo.atlas(678/2+1:678,:,:)-10000; % correct the right hemisphere
%% 2.1 grey matter
greyind=[1,4,9];
greymatter.id=[];
for i=1:length(greyind)
greymatter.id=[greymatter.id;partid_all{greyind(i),2}];
end
[greymatter.map,greymatter.sumpix]=regionread(marmo.atlas,greymatter.id);
% 23522722 pixels in total, .04*.04*.115 micron^3/voxel, ~4328 mm^3
%% 2.2 top layer
% forebrain/cerebrum
forebrain.id=partid_all{1,2};
[forebrain.map,forebrain.sumpix]=regionread(marmo.atlas,forebrain.id);
% brain stem
brainstem.id=partid_all{4,2};
[brainstem.map,brainstem.sumpix]=regionread(marmo.atlas,brainstem.id);
% cerebellum
cerebellum.id=partid_all{9,2};
[cerebellum.map,cerebellum.sumpix]=regionread(marmo.atlas,cerebellum.id);
% calculate ratio
forebrain.ratio=forebrain.sumpix/greymatter.sumpix;
brainstem.ratio=brainstem.sumpix/greymatter.sumpix;
cerebellum.ratio=cerebellum.sumpix/greymatter.sumpix;
%% 2.3 other specific regions
% extract cortex indices
l0=4; % starting layer
cortind=[1,2]; % cortical areas CorA and olfactory cortex OlfC
cortex.id=extractleaf_marmo(partid(:,2:end),l0,cortind,1);  % find all leaf on this branch
[cortex.map,cortex.sumpix]=regionread(marmo.atlas,cortex.id);
cortex.ratio=cortex.sumpix/greymatter.sumpix;
%% thalamus
l0=3; % starting layer
thalaind=6; % top layer index
thalamus.id=extractleaf_marmo(partid(:,2:end),l0,thalaind,1); % find all leaf on this branch
[thalamus.map,thalamus.sumpix]=regionread(marmo.atlas,thalamus.id); 
thalamus.ratio=thalamus.sumpix/greymatter.sumpix;
%% hippocampus
% hippocampus is a special case where the subregions were not delineated
% yet
hippocamp.id=151;
[hippocamp.map,hippocamp.sumpix]=regionread(marmo.atlas,hippocamp.id); 
hippocamp.ratio=hippocamp.sumpix/greymatter.sumpix;
%% save
save('marmosetregions','greymatter','forebrain','brainstem','cerebellum','cortex',...
    'thalamus','hippocamp','allbranches','allbranches_abb')