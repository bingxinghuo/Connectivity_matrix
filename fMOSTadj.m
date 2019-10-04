% L=length(filelist);
outputpath='~/Desktop/fMOST182683/';
tifstack='CH1_3.5_100um.tif';
% mkdir(outputpath);
for i=1:123
    tifimg=imread(['~/Desktop/',tifstack],i);
    if i<30
        bwmask=tifimg>2000;
        bwmask1=medfilt2(bwmask);
        se1=strel('disk',5);
        se2=strel('disk',20);
        bwcenters=imdilate(bwmask1,se1);
        bwsurround=imdilate(bwmask1,se2);
        tifmask1=tifimg.*uint16(bwsurround-bwcenters);
        tifmask2=imfill(tifmask1,18);
        tifmask3=tifmask2.*uint16(bwcenters);
        tifmask4=imdilate(tifmask3,se2).*uint16(bwsurround);
        tifimg1=tifimg.*uint16(1-bwsurround)+uint16(tifmask4);
    elseif i<38
        bwmask=zeros(size(tifimg));
        bwmask(1:1400,1:2200)=1;
        tifimg1=tifimg.*uint16(bwmask);
    else
        tifimg1=tifimg;
    end
    if i==1
        imwrite(tifimg1,[outputpath,tifstack],'writemode','overwrite','compression','none');
    else
        imwrite(tifimg1,[outputpath,tifstack],'writemode','append','compression','none');
    end
end
