%% celldetect_bnb.m
% Modified based on FBdetection_consolid_allimg1_bnb.m
% Bingxing Huo
% This script detects the FB labeled cell bodies in all fluorescent images
% This script calls the following functions:
%     - brainmaskfun_16bit.m or brainmaskfun_8bit.m depending on the images bit depth
%     - FBdetection_consolid.m based on consolidating Keerthi &
%       Bingxing's code
%     - parsave.m to save the results while still within the parfor loop
%%
motorbraininfo(8).animalid='m819';
motorbraininfo(8).modality='mba';
motorbraininfo(8).signalcolor=3;
motorbraininfo(8).inject_sections=162:232; % FB
motorbraininfo(8).injectcolor=3;
motorbraininfo(8).bitinfo=8;
parentpath='/nfs/mitraweb2/mnt/disk125/main/marmosetRIKEN/NZ';
% parentpath='~/CSHLservers/mitragpu3/disk125/main/marmosetRIKEN/NZ';
% marmosetlistfile='~/Documents/GITHUB/Connectivity_matrix/marmosetregionlist.mat';
marmosetlistfile='~/scripts/Connectivity_matrix/marmosetregionlist.mat';
% targetdir='~/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/MotorCortex/';
targetdir='~/';
%%
% myCluster = parcluster('local'); % cores on compute node to be "local"
% addpath(genpath('~/'))
% poolobj=parpool(myCluster, 12);
for i=8
    %% 0. Preparation
    animalid=motorbraininfo(i).animalid;
    bitinfo=motorbraininfo(i).bitinfo;
    color=motorbraininfo(i).signalcolor;
    workpath=[parentpath,'/',motorbraininfo(i).animalid,'/',motorbraininfo(i).animalid,'F/JP2-REG/'];
    tissuemaskdir=[workpath,motorbraininfo(i).animalid,'F-STIF/imgmasks/'];
    savedir=[targetdir,'/',upper(animalid)];
    if ~exist(savedir,'dir')
        mkdir(savedir)
    end
    cd(workpath)
    % 0.1 read in file list
    filelist=jp2lsread;
    Nfiles=length(filelist);
    %% set background standard
    bgfile=[workpath,'/background_standard.mat'];
    tifdir=[workpath,'/',animalid,'F-STIF/'];
    if exist(bgfile,'file')
        load(bgfile); % load bgimgmed0 from contrastadj3.m
    else
        bgfile=[injmaskdir,'/background_standard.mat'];
        if exist(bgfile,'file')
            load(bgfile); % load bgimgmed0 from contrastadj3.m
        else
            % contrastadj3.m
            [~,bgimgmed0,~]=bgstandard(filelist,tifdir,tissuemaskdir,savedir);
        end
    end
    % initialize
    FBclear=cell(Nfiles,1);
    %% 1. Go through every image
    for f=1:Nfiles
        [~,filename,~]=fileparts(filelist{f});
        maskfile=[tissuemaskdir,filename,'.tif'];
        disp(['Processing ',filename,'...'])
        tic;
        % 1.3 detect cells
        centroids=celldet(filelist{f},3,maskfile,bgimgmed0,bitinfo);
        toc;
        disp([filelist{f},' done.'])
        if ~isempty(centroids)
            FBclear{f}.x=centroids(:,1);
            FBclear{f}.y=centroids(:,2);
        else
            FBclear{f}.x=[];
            FBclear{f}.y=[];
        end
    end
%% Save all detected cells into one variable
save([savedir,'/FBdetectdata_consolid'],'FBclear')
end
% delete(poolobj)