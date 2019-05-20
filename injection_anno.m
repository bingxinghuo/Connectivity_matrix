%% injection annotation
% inputs:
% outputs: for each tracer, injection region annotations, injection region
% coordinates on the deformed atlas, center of injection
%
targetdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/MotorCortex/';
datadir='~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/';
animalid='m823';
bitinfo=12;
% set directory
animalid=lower(animalid); % in case the input is upper case
if bitinfo==8
    JP2dir=[datadir,animalid,'/',animalid,'F/JP2-8bit/'];
else
    JP2dir=[datadir,animalid,'/',animalid,'F/JP2/'];
end
flutifdir=[datadir,animalid,'/',animalid,'F/JP2-REG/',lower(animalid),'F-STIF/'];
savedir=[targetdir,upper(animalid),'/injection/'];
if ~exist(savedir,'dir')
    mkdir(savedir)
end
if ~exist(flutifdir,'dir')
    disp('Please generate small tif for registered images first!')
    disp(['Run following code on mitragpu3: ~/scripts/shell_script/convert_jp2_tif_reg.sh ', animalid,' F >/dev/null'])
end
cd(flutifdir)
filelist=filelsread('*.tif');
M=64;
%% set background standard
bgfile=[JP2dir,'/background_standard.mat'];
if ~exist(bgfile,'file')
    % contrastadj3.m
    tifdir=[datadir,animalid,'/',animalid,'F/',upper(animalid),'F-STIF/'];
    maskdir=[datadir,animalid,'/',animalid,'F/JP2/imgmasks/'];
    savedir=[datadir,animalid,'/',animalid,'F/JP2/'];
    [~,bgimgmed0,~]=bgstandard(filelist,tifdir,maskdir,savedir);
else
    bgimgmed0=load(bgfile); % load bgimgmed0 from contrastadj3.m
    bgimgmed0=bgimgmed0.bgimgmed0;
end
%% Set range of interest
% rangeofinterest=325:375; % 1146
% rangeofinterest=239:377; % 1144
% rangeofinterest=256:342; % 920 Note: don't include FB
% rangeofinterest=269:331; % 1147
% rangeofinterest=288:313; % 1148
% rangeofinterest=197:269; % 919
% rangeofinterest=289:399; % 822
% rangeofinterest=[80:102,243:300]; % 820
% rangeofinterest=51:190; % 1228
% rangeofinterest=25:130; % 852
% rangeofinterest=131:245; % 921
rangeofinterest=63:112; % 823
rangeind=1:length(rangeofinterest);
%% Detect injection extent (inject_extent.m)
if ~exist('rangeofinterest','var')
    rangeofinterest=1:length(filelist);
end
injmaskdir=[flutifdir,'/injmasks/'];
if ~exist(injmaskdir,'dir')
    mkdir(injmaskdir);
end
tifmaskdir=[flutifdir,'/imgmasks/'];
if ~exist(tifmaskdir,'dir')
    mkdir(tifmaskdir);
end
%%
for f=rangeofinterest
    injmaskfile=[injmaskdir,'/injmaskdata_',num2str(f),'.tif'];
    % injmaskfile=['injmasks/injmaskdata_',num2str(f)]; % M1144 & 1146
    if ~exist(injmaskfile,'file')
        fileid=filelist{f}(1:end-4);
        % 1.2 generate mask (brainmaskfun_reg.m)
        maskfile=[tifmaskdir,'/imgmaskdata_',num2str(f)];
        if ~exist(maskfile,'file')
            fluimg=imread(fileid,'tif');
            imgmask=brainmaskfun_reg(fluimg);
            imwrite(imgmask,maskfile,'tif')
        else
            imgmask=imread(maskfile);
        end
        inj_maskrgb=injection_extent(fileid,imgmask,bgimgmed0,injmaskfile);
    else
        inj_maskrgb=imread(injmaskfile);
    end
end

%% 3D overlay
% get 3D reconstruction of annotation
annoimgfile=[targetdir,upper(animalid),'/',animalid,'_annotation.img'];
seclistfile=[targetdir,upper(animalid),'/',upper(animalid),'F_anno_seclist.csv']; % correspondence file
flips=[];
% flips=[1,2]; % 820 flip caudal-ventral; flip AP
[annoimgs,seclist]=loadannoimg(annoimgfile,seclistfile,flips);
[H1,N1,W1]=size(annoimgs);
% anno3D
%%
% get 3D reconstruction of injection mask
% injection_extent.m
% injstack1=uint8(zeros(H,W,C,N1));
% for f=rangeofinterest
%     injstack1(:,:,:,42+seclist{2}(f))=imread([savedir,'/injmaskstack.tiff'],f-rangeofinterest(1)+1);
% end

%% orthogonal views
% inj3Dsurf
%% match the annotation map resolution
injmaskfile=cell(length(rangeind),1);
for f=rangeind
    injmaskfile{f}=[injmaskdir,'/injmaskdata_',num2str(rangeofinterest(f)),'.tif'];
end
seccorr=seclist{2}(rangeofinterest);
injmap=maptoatlas(injmaskfile,annoimgs,.96,M,80,seccorr);
%% summarize
injmaparea=cell(3,1);
% separate color channels and save in 3D
% 1. by color channel
for c=1:3
    injmap_anno=uint16(zeros(size(annoimgs)));
    % 2. record all voxel locations on annotation.img
    % (note: later on we can apply the distortion map to restore the true volume)
    for f=rangeind
        injmap_anno(:,N1-40-seclist{2}(rangeofinterest(f))+1,:)=uint16(flip(injmap{f,c},1)); % flip back
        % map back to the annotation.img
    end    
    % save
    for w=1:W1
        if w==1
            imwrite(injmap_anno(:,:,w),[savedir,'/injanno',num2str(c),'stack.tiff'],'writemode','overwrite','compression','none')
        else
            imwrite(injmap_anno(:,:,w),[savedir,'/injanno',num2str(c),'stack.tiff'],'writemode','append','compression','none')
        end
    end
% 3. summarize region atlas labels and voxel numbers, A-by-2 matrix
injannolist=unique(nonzeros(injmap_anno));
A=length(injannolist);
injmaparea{c}=zeros(A,2);
for a=1:A
    injmaparea{c}(a,1)=injannolist(a);
    injmaparea{c}(a,2)=sum(sum(sum(injmap_anno==injannolist(a))));
end
end
save([savedir,'/injareaanno.mat'],'injmaparea')