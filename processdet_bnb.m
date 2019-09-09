 motorbraininfo(1).animalid='m820';
motorbraininfo(1).modality='mba';
motorbraininfo(1).signalcolor=1;
motorbraininfo(1).bitinfo=8;
motorbraininfo(1).originresolution=.46*2;
motorbraininfo(1).flips=[]; % rotations needed to orient the annotation to the same as the histology stack
motorbraininfo(2).animalid='m821';
motorbraininfo(2).modality='mba';
motorbraininfo(2).signalcolor=1;
motorbraininfo(2).bitinfo=12;
motorbraininfo(2).originresolution=1.4;
motorbraininfo(2).flips=[1,2];
motorbraininfo(3).animalid='m823';
motorbraininfo(3).modality='mba';
motorbraininfo(3).signalcolor=[1,2];
% motorbraininfo(3).signalcolor=[1];
motorbraininfo(3).bitinfo=12;
motorbraininfo(3).originresolution=.46*2;
motorbraininfo(3).flips=[1,2];
motorbraininfo(4).animalid='m852';
motorbraininfo(4).modality='mba';
motorbraininfo(4).signalcolor=2;
motorbraininfo(4).bitinfo=12;
motorbraininfo(4).originresolution=1.4;
motorbraininfo(4).flips=[1,2];
motorbraininfo(5).animalid='m917';
motorbraininfo(5).modality='mba';
motorbraininfo(5).signalcolor=2;
motorbraininfo(5).bitinfo=12;
motorbraininfo(5).originresolution=1.4;
motorbraininfo(5).flips=[1,2];
motorbraininfo(6).animalid='m921';
motorbraininfo(6).modality='mba';
motorbraininfo(6).signalcolor=2;
motorbraininfo(6).bitinfo=12;
motorbraininfo(6).originresolution=1.4;
motorbraininfo(6).flips=[1,2];
motorbraininfo(7).animalid='m1228';
motorbraininfo(7).modality='mba';
motorbraininfo(7).signalcolor=2;
motorbraininfo(7).bitinfo=12;
motorbraininfo(7).originresolution=.46*2;
motorbraininfo(7).flips=[1,2];
% parentpath='/Users/bhuo/CSHLservers/mitragpu3/disk125/main/marmosetRIKEN/NZ';
parentpath='/nfs/mitraweb2/mnt/disk125/main/marmosetRIKEN/NZ';
marmosetlistfile='~/scripts/Connectivity_matrix/marmosetregionlist.mat';
% targetdir='~/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/MotorCortex/';
targetdir='~/';
%%
myCluster = parcluster('local'); % cores on compute node to be "local"
poolobj=parpool(myCluster, 10);
addpath(genpath('~/scripts/'))
for i=1:length(motorbraininfo)
    animalid=motorbraininfo(i).animalid;
    signalcolor=motorbraininfo(i).signalcolor;
    bitinfo=motorbraininfo(i).bitinfo;
    workpath=[parentpath,'/',animalid,'/',animalid,'F/JP2-REG/'];
    tissuemaskdir=[workpath,animalid,'F-STIF/imgmasks/'];
    savedir=[targetdir,'/',upper(animalid)];
    if ~exist(savedir,'dir')
        mkdir(savedir)
    end
    cd(workpath)
    % test writing permission of workpath
    if ~system('ls > test.txt') % if successful (success=0)
        procmaskdir=[workpath,'/processmask/'];
        system('rm test.txt');
    else
        % if no writing permission to the workpath
        procmaskdir=[savedir,'/processmask/'];
    end
    if ~exist(procmaskdir,'dir')
        mkdir(procmaskdir)
    end
    filelist=filelsread('*.jp2',savedir);
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
    parfor f=1:length(filelist)
        [~,filename,~]=fileparts(filelist{f});
        maskfile=[tissuemaskdir,filename,'.tif'];
        procmaskfile=[procmaskdir,'/',filename,'.tif'];
        disp(['Processing ',filename,'...'])
        tic;
        signaldet(filelist{f},signalcolor,maskfile,bgimgmed0,bitinfo,procmaskfile);
        toc;
        disp([filelist{f},' done.'])
    end
    %     [outputdir,~,~]=fileparts(procmaskdir); % remove "/" on the end
    %     neuronvoxelize(motorbraininfo(i),tissuemaskdir,outputdir,savedir,motorbraininfo(i).originresolution,80,'process');
    %     regionneuronsummary(motorbraininfo(i),['process_',num2str(signalcolor(c))],savedir,marmosetlistfile);
    
end
delete(poolobj)