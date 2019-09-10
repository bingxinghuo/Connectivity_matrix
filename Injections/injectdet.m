motorbraininfo(1).animalid='m820';
motorbraininfo(1).modality='mba';
motorbraininfo(1).signalcolor=1;
motorbraininfo(1).bitinfo=8;
motorbraininfo(1).originresolution=.46*2;
motorbraininfo(1).inject_sections=81:94;
motorbraininfo(1).injectcolor=1;
motorbraininfo(1).flips=[]; % rotations needed to orient the annotation to the same as the histology stack
motorbraininfo(2).animalid='m821';
motorbraininfo(2).modality='mba';
motorbraininfo(2).signalcolor=1;
motorbraininfo(2).bitinfo=12;
motorbraininfo(2).originresolution=1.4;
motorbraininfo(2).inject_sections=35:103;
motorbraininfo(2).injectcolor=1;
motorbraininfo(2).flips=[1,2];
motorbraininfo(3).animalid='m823';
motorbraininfo(3).modality='mba';
motorbraininfo(3).signalcolor=[2;1];
motorbraininfo(3).bitinfo=12;
motorbraininfo(3).originresolution=.46*2;
motorbraininfo(3).inject_sections=63:112;
motorbraininfo(3).injectcolor=1:3;
motorbraininfo(3).flips=[1,2];
motorbraininfo(4).animalid='m852';
motorbraininfo(4).modality='mba';
motorbraininfo(4).signalcolor=2;
motorbraininfo(4).bitinfo=12;
motorbraininfo(4).originresolution=1.4;
motorbraininfo(4).inject_sections=91:130;
motorbraininfo(4).injectcolor=2:3;
motorbraininfo(4).flips=[1,2];
motorbraininfo(5).animalid='m917';
motorbraininfo(5).modality='mba';
motorbraininfo(5).signalcolor=2;
motorbraininfo(5).bitinfo=12;
motorbraininfo(5).originresolution=1.4;
motorbraininfo(5).inject_sections=2:110;
motorbraininfo(5).injectcolor=2:3;
motorbraininfo(5).flips=[1,2];
motorbraininfo(6).animalid='m921';
motorbraininfo(6).modality='mba';
motorbraininfo(6).signalcolor=2;
motorbraininfo(6).bitinfo=12;
motorbraininfo(6).originresolution=1.4;
motorbraininfo(6).inject_sections=131:245;
motorbraininfo(6).injectcolor=2;
motorbraininfo(6).flips=[1,2];
motorbraininfo(7).animalid='m1228';
motorbraininfo(7).modality='mba';
motorbraininfo(7).signalcolor=2;
motorbraininfo(7).bitinfo=12;
motorbraininfo(7).originresolution=.46*2;
motorbraininfo(7).inject_sections=140:190;
motorbraininfo(7).injectcolor=2;
motorbraininfo(7).flips=[1,2];
motorbraininfo(8).animalid='m819';
motorbraininfo(8).modality='mba';
motorbraininfo(8).bitinfo=8;
motorbraininfo(8).originresolution=.46*2;
motorbraininfo(8).signalcolor=3;
motorbraininfo(8).inject_sections=162:232; % FB
motorbraininfo(8).injectcolor=3;
motorbraininfo(9).animalid='m918';
motorbraininfo(9).modality='mba';
motorbraininfo(9).bitinfo=12;
motorbraininfo(9).signalcolor=3;
motorbraininfo(9).originresolution=1.4;
motorbraininfo(9).inject_sections=1:91; % FB
motorbraininfo(9).injectcolor=3;
parentpath='/Users/bhuo/CSHLservers/mitragpu3/disk125/main/marmosetRIKEN/NZ';
marmosetlistfile='~/Documents/GITHUB/Connectivity_matrix/marmosetregionlist.mat';
targetdir='~/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/MotorCortex/';
%%
% myCluster = parcluster('local'); % cores on compute node to be "local"
% poolobj=parpool(myCluster, 10);
% addpath(genpath('~/scripts/'))
% for i=4:length(motorbraininfo)
for i=8
    animalid=motorbraininfo(i).animalid;
    rangeofinterest=motorbraininfo(i).inject_sections;
    bitinfo=motorbraininfo(i).bitinfo;
    injcolor=motorbraininfo(i).injectcolor;
    workpath=[parentpath,'/',motorbraininfo(i).animalid,'/',motorbraininfo(i).animalid,'F/JP2-REG/'];
    tissuemaskdir=[workpath,motorbraininfo(i).animalid,'F-STIF/imgmasks/'];
    cd(workpath)
    if ~system('ls > test.txt') % if successful (success=0)
        injmaskdir=[workpath,'/injmasks/'];
        system('rm test.txt');
    else
        % if no writing permission to the workpath
        injmaskdir=[targetdir,'/',motorbraininfo(i).animalid,'/injmasks/'];
    end
    if ~exist(injmaskdir,'dir')
        mkdir(injmaskdir)
    end
    filelist=jp2lsread;
    %% set background standard
    %     bgfile=[workpath,'/background_standard.mat'];
    %     tifdir=[workpath,'/',animalid,'F-STIF/'];
    %     if exist(bgfile,'file')
    %         load(bgfile); % load bgimgmed0 from contrastadj3.m
    %     else
    %         bgfile=[injmaskdir,'/background_standard.mat'];
    %         if exist(bgfile,'file')
    %             load(bgfile); % load bgimgmed0 from contrastadj3.m
    %         else
    %             % contrastadj3.m
    %             [~,bgimgmed0,~]=bgstandard(filelist,tifdir,tissuemaskdir,injmaskdir);
    %         end
    %     end
    %     cd(tifdir)
    %     for f=rangeofinterest
    %         [~,filename,~]=fileparts(filelist{f});
    %         disp(['Processing ',filename,'...'])
    %         maskfile=[tissuemaskdir,filename,'.tif'];
    %         if ~exist(maskfile,'file')
    %             maskfile=[tissuemaskdir,'imgmaskdata_',num2str(f)];
    %         end
    %         imgmask=imread(maskfile);
    %         injmaskfile=[injmaskdir,filename,'.tif'];
    %         injection_extent(filename,imgmask,bgimgmed0,injcolor,injmaskfile);
    %         disp([filelist{f},' done.'])
    %     end
    savedir=[targetdir,'/',motorbraininfo(i).animalid];
    [injdir,~,~]=fileparts(injmaskdir); % remove "/" on the end
    neurondensity=neuronvoxelize(motorbraininfo(i),tissuemaskdir,injdir,savedir,motorbraininfo(i).originresolution*64,80,'inject');
    regionneuronsummary(motorbraininfo(i),'inject',[targetdir,'/',motorbraininfo(i).animalid],marmosetlistfile);
end
% delete(poolobj)