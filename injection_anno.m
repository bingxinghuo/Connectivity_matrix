%% injection annotation
% inputs:
% outputs: for each tracer, injection region annotations, injection region
% coordinates on the deformed atlas, center of injection
%
% targetdir='~/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/MotorCortex/';
% datadir='~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/';
% dsrate=64;
%% Set animal-specific parameters
% datainfo.animalid='m1146'; datainfo.inject_sections=325:375; datainfo.originresolution=.92; datainfo.bitinfo=12; % 1146
% datainfo.animalid='m1144'; datainfo.inject_sections=239:377; datainfo.originresolution=.92; datainfo.bitinfo=12; % 1144
% datainfo.animalid='m920'; datainfo.inject_sections=256:342; datainfo.originresolution=1.4; datainfo.bitinfo=12; % 920 Note: don't include FB
% datainfo.animalid='m1147'; datainfo.inject_sections=269:331; datainfo.originresolution=.92; datainfo.bitinfo=12; % 1147
% datainfo.animalid='m1148'; datainfo.inject_sections=288:313; datainfo.originresolution=.92; datainfo.bitinfo=12; % 1148
% datainfo.animalid='m919'; datainfo.inject_sections=197:269; datainfo.originresolution=.92; datainfo.bitinfo=12; % 919
% datainfo.animalid='m822'; datainfo.inject_sections=289:399; datainfo.originresolution=.92; datainfo.bitinfo=8; % 822
% datainfo.animalid='m820'; datainfo.inject_sections=[80:102,243:300]; datainfo.originresolution=.92; datainfo.bitinfo=8; datainfo.flips=[1,2]; % 820
% datainfo.animalid='m1228'; datainfo.inject_sections=51:190; datainfo.originresolution=.92; datainfo.bitinfo=12; % 1228
% datainfo.animalid='m852'; datainfo.inject_sections=25:130; datainfo.originresolution=1.38; datainfo.bitinfo=12; % 852
% datainfo.animalid='m921'; datainfo.inject_sections=131:245; datainfo.originresolution=1.4; datainfo.bitinfo=12; % 921
% datainfo.animalid='m823'; datainfo.inject_sections=63:112; datainfo.originresolution=.92; datainfo.bitinfo=8; % 823
% datainfo.animalid='m821'; datainfo.inject_sections=35:103; datainfo.originresolution=1.4; datainfo.bitinfo=12; % 821
% datainfo.animalid='m917'; datainfo.inject_sections=2:110; datainfo.originresolution=1.38; datainfo.bitinfo=12;
% datainfo.animalid='m918'; datainfo.inject_sections=1:91; datainfo.originresolution=1.38; datainfo.bitinfo=12;
function injmap=injection_anno(datainfo,datadir,targetdir,dsrate,annores,regionlistfile)
animalid=datainfo.animalid;
rangeofinterest=datainfo.inject_sections;
bitinfo=datainfo.bitinfo;
if isfield(datainfo,'flips')
    flips=[];
else
    flips=datainfo.flips;
end
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
% injmaskdir=[flutifdir,'/injmasks/'];
injmaskdir=[savedir,'/injmasks/'];
if ~exist(injmaskdir,'dir')
    mkdir(injmaskdir);
end
% tifmaskdir=[flutifdir,'/imgmasks/'];
tifmaskdir=[savedir,'/imgmasks/'];
if ~exist(tifmaskdir,'dir')
    mkdir(tifmaskdir);
end
cd(flutifdir)
filelist=filelsread('*.tif');
if ~exist('rangeofinterest','var')
    rangeofinterest=1:length(filelist);
end
rangeind=1:length(rangeofinterest);
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
%% Detect injection extent (inject_extent.m)
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
annoimgfile=[targetdir,upper(animalid),'/',upper(animalid),'_annotation.img'];
seclistfile=[targetdir,upper(animalid),'/',upper(animalid),'F_anno_seclist.csv']; % correspondence file
[annoimgs,seclist]=loadannoimg(annoimgfile,seclistfile,flips);
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
%% map to annotation and save the volume
injmaskfile=cell(length(rangeind),1);
for f=rangeind
    injmaskfile{f}=[injmaskdir,'/injmaskdata_',num2str(rangeofinterest(f)),'.tif'];
end
seccorr=seclist{2}(rangeofinterest);
injmap=maptoatlas(injmaskfile,annoimgs,seccorr,datainfo.originresolution,dsrate,annores,[savedir,'/injannostack.tiff']);
%% summarize
region_density_list(injmap,annoimg,[savedir,'/injareaanno.csv']);
% if there ist LUT, overwrite.
if nargin>5
    if ~isempty(regionlistfile)
        try
            regionLUT=load(regionlistfile);
            field=fieldnames(regionLUT);
            regionLUT=getfield(regionLUT,field{1});
            region_density_list(injmap,annoimg,[savedir,'/injareaanno.csv'],regionLUT);
        catch
            
        end
    end
end