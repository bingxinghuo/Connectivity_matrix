%% assemble 3D reconstruction
[H,W,C]=size(inj_maskrgb);
N=length(filelist);
injstack=uint8(zeros(H,W,C,N));
for f=rangeofinterest
    injmaskfile=['injmasks/injmaskdata_',num2str(f)];
    inj_maskrgb=imread(injmaskfile,'tif');
    %     injstack(:,:,:,f)=inj_maskrgb;
    if f==rangeofinterest(1)
        imwrite(inj_maskrgb,[savedir,'/injmaskstack.tiff'],'writemode','overwrite','compression','none')
    else
        imwrite(inj_maskrgb,[savedir,'/injmaskstack.tiff'],'writemode','append','compression','none')
    end
end
%% get outline of the brain
% maxintproj.m
% conversion_factor=round(80/(.46*3)); %920
conversion_factor=round(80/(.46*2));
% coronal view
annocor=sum(annoimgs,2);
annocor1=flipdim(annocor,1);
bwcor=annocor1>0;
bwcor=squeeze(bwcor);
bwcor1=repelem(bwcor,conversion_factor,conversion_factor);
bwcor2=downsample_max(bwcor1,64,64);
bwcor2=bwcor2(1:H,1:W);
bwcor2=imfill(bwcor2,'holes');
bwcoredge=edge(bwcor2);
bwcorcontour=cat(3,bwcoredge,bwcoredge,bwcoredge);
% sagittal view
annosag=sum(annoimgs,3);
annosag1=flipdim(annosag,1);
annosag1=flipdim(annosag1,2);
bwsag=annosag1>0;
bwsag1=repelem(bwsag,conversion_factor,1);
bwsag2=downsample_max(bwsag1,64,1);
bwsag2=bwsag2(1:H,:);
bwsag2=imfill(bwsag2,'holes');
bwsagedge=edge(bwsag2);
bwsagcontour=cat(3,bwsagedge,bwsagedge,bwsagedge);
% transverse view
annotrans=sum(annoimgs,1);
annotrans1=squeeze(annotrans);
annotrans2=imrotate(annotrans1,-90);
bwtrans=annotrans2>0;
bwtrans1=repelem(bwtrans,conversion_factor,1);
bwtrans2=downsample_max(bwtrans1,64,1);
bwtrans2=bwtrans2(1:W,:);
bwtrans2=imfill(bwtrans2,'holes');
bwtransedge=edge(bwtrans2);
bwtranscontour=cat(3,bwtransedge,bwtransedge,bwtransedge);
%% visualization
% cor_anno=double(regioncor3)/255+double(injmaxcor1)+double(bwcorcontour);
% sag_anno=double(regionsag3)/255+double(injmaxsag1)+double(bwsagcontour);
% trans_anno=double(regiontrans3)/255+double(injmaxtrans1)+double(bwtranscontour);
cor_anno=double(injmaxcor1)+double(bwcorcontour);
sag_anno=double(injmaxsag1)+double(bwsagcontour);
trans_anno=double(injmaxtrans1)+double(bwtranscontour);
% figure, imagesc(double(regioncor3)/255+double(injmaxcor1)+double(bwcorcontour))
% figure, imagesc(double(regionsag3)/255+double(injmaxsag1)+double(bwsagcontour))
% figure, imagesc(double(regiontrans3)/255+double(injmaxtrans1)+double(bwtranscontour))
imwrite(cor_anno,[savedir,upper(animalid),'_inj_anno_cor.png'],'png')
imwrite(sag_anno,[savedir,upper(animalid),'_inj_anno_sag.png'],'png')
imwrite(trans_anno,[savedir,upper(animalid),'_inj_anno_trans.png'],'png')