
%% Hashikawa color code
% treedata=loadjson('/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Connectivity/marmoset brain/regions.json');
%% subregions
warning('off')
% regionids=[142,143,149]; %V1, V2, V6
regionids=[31:37,41]; % motor cortex
R=length(regionids);
anno3Dsurf % orthogonal projections
%% brain outline with subregions
% coronal
annocor=sum(annoimgs,2);
annocor1=flipdim(annocor,1);
% annocor1=flipdim(annocor1,2);
bwcor=annocor1>0;
bwcor=squeeze(bwcor);
% bwcor1=repelem(bwcor,87,87);
% bwcor2=downsample_max(bwcor1,64,64);
% bwcor2=bwcor2(1:H,1:W);
bwcor2=imfill(bwcor,'holes');
braincoredge=bwboundaries(bwcor2);
Nedgecount=length(braincoredge);
if Nedgecount>1
    edgecount=zeros(Nedgecount,1);
    for i=1:Nedgecount
        edgecount(i)=size(braincoredge{i},1);
    end
    [~,edgei]=max(edgecount);
    braincoredge=braincoredge{edgei};
else
    braincoredge=braincoredge{1};
end
braincor=polyshape(braincoredge);
% sagittal
annosag=sum(annoimgs,3);
annosag1=flipdim(annosag,1);
annosag1=flipdim(annosag1,2);
bwsag=annosag1>0;
% bwsag1=repelem(bwsag,87,1);
% bwsag2=downsample_max(bwsag1,64,1);
% bwsag2=bwsag2(1:H,:);
bwsag2=imfill(bwsag,'holes');
brainsagedge=bwboundaries(bwsag2);
Nedgecount=length(brainsagedge);
if Nedgecount>1
    edgecount=zeros(Nedgecount,1);
    for i=1:Nedgecount
        edgecount(i)=size(brainsagedge{i},1);
    end
    [~,edgei]=max(edgecount);
    brainsagedge=brainsagedge{edgei};
else
    brainsagedge=brainsagedge{1};
end
brainsag=polyshape(brainsagedge);
% transverse
annotrans=sum(annoimgs,1);
annotrans1=squeeze(annotrans);
annotrans2=imrotate(annotrans1,-90);
bwtrans=annotrans2>0;
% bwtrans1=repelem(bwtrans,87,1);
% bwtrans2=downsample_max(bwtrans1,64,1);
% bwtrans2=bwtrans2(1:W,:);
bwtrans2=imfill(bwtrans,'holes');
braintransedge=bwboundaries(bwtrans2);
Nedgecount=length(braintransedge);
if Nedgecount>1
    edgecount=zeros(Nedgecount,1);
    for i=1:Nedgecount
        edgecount(i)=size(braintransedge{i},1);
    end
    [~,edgei]=max(edgecount);
    braintransedge=braintransedge{edgei};
else
    braintransedge=braintransedge{1};
end
braintrans=polyshape(braintransedge);
%% visualization
% regioncor1=label2rgb(regioncor,'lines');
% regionsag1=label2rgb(regionsag,'lines');
% regiontrans1=label2rgb(regiontrans,'lines');
% % regioncor=xyz2rgb(regioncorxyz);
% imwrite((regioncor1),'annocoronal.tif','writemode','overwrite')
% imwrite((regionsag1),'annosagittal.tif','writemode','overwrite')
% imwrite((regiontrans1),'annotransverse.tif','writemode','overwrite')
% coronal
figure, hold on
for i=1:R
    for k=1:length(regioncor{i})
        if ~isempty(regioncor{i}{k})
        plot(regioncor{i}{k})
        end
    end
end
plot(braincor)
axis image
axis off
alpha 1
print([savedir,upper(animalid),'_coronal_regions1.eps'],'-depsc')
% sagittal
figure, hold on
for i=1:R
    for k=1:length(regionsag{i})
        if ~isempty(regionsag{i}{k})
        plot(regionsag{i}{k})
        end
    end
end
plot(brainsag)
axis image
axis off
alpha 1
print([savedir,upper(animalid),'_sag_regions1.eps'],'-depsc')
% transverse
figure, hold on
for i=1:R
    for k=1:length(regiontrans{i})
        if ~isempty(regiontrans{i}{k})
        plot(regiontrans{i}{k})
        end
    end
end
plot(braintrans)
axis image
axis off
alpha 1
print([savedir,upper(animalid),'_trans_regions1.eps'],'-depsc')