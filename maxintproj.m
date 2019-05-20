%% maximal intensity projection
targetdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Paul Martin/';
datadir='~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/';
animalid='m820';
% set directory
animalid=lower(animalid); % in case the input is upper case
flutifdir=[datadir,animalid,'/',animalid,'F/JP2-REG/',lower(animalid),'F-STIF/'];
savedir=[targetdir,upper(animalid),'/injection/'];
if ~exist(savedir,'dir')
    mkdir(savedir)
end
%% 0. parameters
cd(flutifdir)
if ~exist([pwd,'/imgmasks'],'dir')
    mkdir('imgmasks')
end
% load('../../JP2/background_standard.mat') % load bgimgmed0
filelist=filelsread('*.tif');
%% 1. generate a 4D stack of fluorescent images, in 8-bit
% rangeofinterest=200:375;
rangeofinterest=1:length(filelist);
N=length(rangeofinterest);
imgsize=imfinfo(filelist{1});
W=imgsize.Width;
H=imgsize.Height;
C=3;
%
flustack=uint8(zeros(H,W,C,N));
for f=rangeofinterest
    tic
    tiffile=filelist{f};
    disp(['Processing ',tiffile,'...',num2str(f-rangeofinterest(1)+1),'/',num2str(N)])
    fluimg=imread(tiffile);
    fluimg=uint8(fluimg);
    maskfile=['imgmasks/imgmaskdata_',num2str(f)];
    if ~exist(maskfile,'file')
        imgmask=brainmaskfun_reg(fluimg);
        imwrite(imgmask,maskfile,'tif')
    else
        imgmask=imread(maskfile);
    end
    % 2. adjust background (bgmean3.m)
    % 2.1 Calculate background median
    threshmask=fluimg<50; % threshold for forground/backgrond distinction
    % threshold background
    flubg=fluimg.*cast(threshmask,'like',fluimg);
    imgmask1=cast(imgmask,'like',fluimg);
    % get tissue
    brainimg=flubg.*cat(3,imgmask1,imgmask1,imgmask1);
    % calculate median
    fluimgpix=cell(3,1);
    bgimgmed=zeros(3,1);
    for c=1:3
        fluimgpix{c}=nonzeros(brainimg(:,:,c)); % collect all nonzeros pixels
        bgimgmed(c)=median(fluimgpix{c});
    end
    % 2.2 force background to zero
    adjmat=ones(H,W,3);
    adjmat=double(adjmat);
    for c=1:3
        %         adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
        adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c));
    end
    fluimg1=double(fluimg)-adjmat;
    fluimg1=fluimg1.*(fluimg1>0);
    % 3. color filter (hsvadjcolor.m)
    fluhsv=rgb2hsv(fluimg1);
    cmask=(fluhsv(:,:,1)>=(80/360)).*(fluhsv(:,:,1)<=(150/360))... % green
        +(fluhsv(:,:,1)>=(170/360)).*(fluhsv(:,:,1)<=(230/360))... % blue
        +(fluhsv(:,:,1)>=(340/360))+(fluhsv(:,:,1)<=(10/360)); % red
    fluhsv(:,:,1)=cmask.*fluhsv(:,:,1); %
    fluhsv(:,:,2)=cmask;
    fluhsv(:,:,3)=fluhsv(:,:,3).*cmask;
    fluimg2=hsv2rgb(fluhsv);
    fluimg3=uint8(fluimg2).*uint8(cat(3,imgmask,imgmask,imgmask));
    flustack(:,:,:,f-rangeofinterest(1)+1)=fluimg3;
    toc
    if f==rangeofinterest(1)
        imwrite(fluimg3,[savedir,upper(animalid),'_flustack.tiff'],'writemode','overwrite','compression','none')
    else
        imwrite(fluimg3,[savedir,upper(animalid),'_flustack.tiff'],'writemode','append','compression','none')
    end
end
%%
% load annotation 
annostack=load_nii([targetdir,upper(animalid),'/',animalid,'_annotation.img']);
annoimgs=annostack.img; 
annoimgs(annoimgs>=10000)=annoimgs(annoimgs>=10000)-10000; % adjust LR hemisphere difference
N1=size(annoimgs,2);
% load correspondence
fid=fopen([savedir,'../',upper(animalid),'F_anno_seclist.csv']); % output from F_REG_secnum.py
seclist=textscan(fid,'%q %u','Delimiter',',');
fclose(fid);
%% 2. Get maximal intensity for coronal view
flumaxcor=uint8(zeros(H,W,C));
for c=1:C
    for h=1:H
        for w=1:W
            flumaxcor(h,w,c)=max(flustack(h,w,c,:));
        end
    end
end
% use the max annotation contour
annocor=sum(annoimgs,2);
% annocor1=flipdim(annocor,1);
% annocor1=flipdim(annocor1,2);
annocor1=annocor; % m820
bwcor=annocor1>0;
bwcor=squeeze(bwcor);
bwcor1=repelem(bwcor,87,87);
bwcor2=downsample_max(bwcor1,64,64);
bwcor2=bwcor2(1:H,1:W);
bwcor2=imfill(bwcor2,'holes');
bwcoredge=edge(bwcor2);
% combine
flumaxcor_contour=flumaxcor+uint8(cat(3,bwcoredge,bwcoredge,bwcoredge)*255);
figure, imagesc(flumaxcor_contour)
axis image
axis off
imwrite(flumaxcor_contour,[savedir,animalid,'_maxintproj_coronal.png'])
clear bwcor*
%% 3. Get maximal intensity for sagittal view
flumaxsag=uint8(zeros(H,N1,C));
for c=1:C
    for h=1:H
        for n=1:N
            flumaxsag(h,42+seclist{2}(n),c)=max(flustack(h,:,c,n));
        end
    end
end
annosag=sum(annoimgs,3);
% annosag1=flipdim(annosag,1);
% annosag1=flipdim(annosag1,2);
annosag1=annosag; % m820
bwsag=annosag1>0;
bwsag1=repelem(bwsag,87,1);
bwsag2=downsample_max(bwsag1,64,1);
bwsag2=bwsag2(1:H,:);
bwsag2=imfill(bwsag2,'holes');
bwsagedge=edge(bwsag2);
flumaxsag_contour=flumaxsag+uint8(cat(3,bwsagedge,bwsagedge,bwsagedge)*255);
figure, imagesc(flumaxsag_contour)
axis image
axis off
imwrite(flumaxsag_contour,[savedir,animalid,'_maxintproj_sagittal.png'])
clear bwsag*
%% 4. Get maximal intensity for transverse view
flumaxtrans=uint8(zeros(W,N1,C));
for c=1:C
    for w=1:W
        for n=1:N
            flumaxtrans(w,42+seclist{2}(n),c)=max(flustack(:,w,c,n));
        end
    end
end
%
annotrans=sum(annoimgs,1);
annotrans1=squeeze(annotrans);
% annotrans2=imrotate(annotrans1,-90);
annotrans2=imrotate(annotrans1,90); % m820
bwtrans=annotrans2>0;
bwtrans1=repelem(bwtrans,87,1);
bwtrans2=downsample_max(bwtrans1,64,1);
bwtrans2=bwtrans2(1:W,:);
bwtrans2=imfill(bwtrans2,'holes');
bwtransedge=edge(bwtrans2);
flumaxtrans_contour=flumaxtrans+uint8(cat(3,bwtransedge,bwtransedge,bwtransedge)*255);
figure, imagesc(flumaxtrans_contour)
axis image
axis off
imwrite(flumaxtrans_contour,[savedir,animalid,'_maxintproj_transverse.png'])
clear bwtrans*
