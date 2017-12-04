% extract mouse brain information
% 1. from json file, extract all the grey matter lowest level id's
% 2. read out the whole brain grey matter volume
% 3. from json file, extract id's for individual brain regions (high level)
% 4. read out the specific brain region volume
% 5. Calculate the proportions in %

%% 1. from json file, extract all the grey matter lowest level id's
lutb=loadjson('1.json');
% 1.1 level 0: grey matter
greydata=lutb.msg{1}.children{1}; % greydata contains all the grey matter
[greymatter.id,greymatter.branches]=extractleaf(greydata);
%% 2. read out the whole brain grey matter volume
load('annotation_py.mat')
[greymatter.map,greymatter.sumpix]=regionread(arr,greyid);   
% 26332136 pixels in 25-micron isotropic atlas, ~411 mm^3
%% 3. from json file, extract id's for individual brain regions (high level)
% 3.1 top layer: cerebrum, brain stem and cerebellum
[cerebrum.id,cerebrum.branches]=extractleaf(greydata.children{1});
[brainstem.id,brainstem.branches]=extractleaf(greydata.children{2});
[cerebellum.id,cerebellum.branches]=extractleaf(greydata.children{3});
% 3.2 other specific regions: cerebral cortex, thalamus
[cortex.id,cortex.branches]=extractleaf(greydata.children{1}.children{1});
[thalamus.id,thalamus.branches]=extractleaf(greydata.children{2}.children{1}.children{1});
[hippocamp.id,hippocamp.branches]=extractleaf(greydata.children{1}.children{1}.children{1}.children{3});
%% 4. read out the specific brain region volume
[cerebrum.map,cerebrum.sumpix]=regionread(arr,cerebrum.id);
[brainstem.map,brainstem.sumpix]=regionread(arr,brainstem.id);
[cerebellum.map,cerebellum.sumpix]=regionread(arr,cerebellum.id);
[cortex.map,cortex.sumpix]=regionread(arr,cortex.id);
[thalamus.map,thalamus.sumpix]=regionread(arr,thalamus.id);
[hippocamp.map,hippocamp.sumpix]=regionread(arr,hippocamp.id);
%% 5. Calculate the proportions
cerebrum.ratio=cerebrum.sumpix/greymatter.sumpix;
brainstem.ratio=brainstem.sumpix/greymatter.sumpix;
cerebellum.ratio=cerebellum.sumpix/greymatter.sumpix;
cortex.ratio=cortex.sumpix/greymatter.sumpix;
thalamus.ratio=thalamus.sumpix/greymatter.sumpix;
hippocamp.ratio=hippocamp.sumpix/greymatter.sumpix;
%% 6. Save
save('mouseregions','greymatter','cerebrum','brainstem','cerebellum','cortex','thalamus','hippocamp'c)