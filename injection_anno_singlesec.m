% set up parameters with injection_anno.m
%% coronal
[fileind,fileid]=jp2ind(filelist,'590');
secnum=42+seclist{2}(fileind);
annoimg=squeeze(annostack.img(:,end-secnum+1,:));
annoimg(annoimg>=10000)=annoimg(annoimg>=10000)-10000;
figure, imagesc(annoimg)
axis xy
caxis([140 150])
%% sagittal
cd(flutifdir)
filelist=filelsread('*.tif');
[f,fileid]=jp2ind(filelist,'602');
injmask=imread(['injmasks/injmaskdata_',num2str(f)],'tif');
c=3;
figure, imagesc(injmask(:,:,c))
%%
sagsec=104; % M920, c=3, blue channel
% sagsec=126; % M920, c=1, red channel
injcent=squeeze(injstack1(:,sagsec,c,:));
sagsec_anno=round(sagsec*(.46*3*64)/80);
annocent1=annoimgs(:,:,sagsec_anno); % left limit
annocent2=annoimgs(:,:,sagsec_anno+4); % right limit
annocent1=flip(annocent1,1);
annocent1=flip(annocent1,2);
annocent2=flip(annocent2,1);
annocent2=flip(annocent2,2);
figure, imagesc(injcent)
axis image
print([savedir,upper(animalid),'_sag_injcent.eps'],'-depsc')
figure, imagesc(annocent1)
caxis([140 150])
axis image
print([savedir,upper(animalid),'_sag_injcent_anno1.eps'],'-depsc')
figure, imagesc(annocent2)
caxis([140 150])
axis image
print([savedir,upper(animalid),'_sag_injcent_anno2.eps'],'-depsc')