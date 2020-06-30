%% injectdet_marmoset.m
% by Bingxing Huo, June 2020
% This script runs the injection detection pipeline for marmoset data,
% where injection areas were detected based on downsampled fluorescent
% image intensity.
%% 0. initialize and set parameters
species='marmoset';
detecttype='inject';
tracer='multiple';
modality='mba';
summary_initialize;
%  uiopen([savedir0,'/marmosetdatainfo.xlsx'],1);
% marmosetdatainfo=table2struct(marmosetdatainfo);
% save('marmosetdatainfo','marmosetdatainfo')
load([savedir0,'/marmosetdatainfo.mat']);
N=length(marmosetdatainfo);
%%
% myCluster = parcluster('local'); % cores on compute node to be "local"
% poolobj=parpool(myCluster, 10);
% addpath(genpath('~/scripts/'))
for i=1:N
    %% 1. initialize
    brainID=marmosetdatainfo(i).animalid;
    rangeofinterest=''; % default to the entire range
    % update datainfo based on individual brain
    datainfo.animalid=brainID;
    datainfo.bitinfo=marmosetdatainfo(i).bitinfo;
    injcolor=datainfo.signalcolor;  % default to all colors
    datainfo.flips=str2num(marmosetdatainfo(i).flips);
    cell_init_marmoset_brain;
    %% 2.  set background standard
    bgfile=[regdir,'/background_standard.mat'];
    simgdir=[regdir,'/',animalid,'F-STIF/'];
    if exist(bgfile,'file')
        load(bgfile); % load bgimgmed0 from contrastadj3.m
    else
        bgfile=[injmaskdir,'/background_standard.mat'];
        if exist(bgfile,'file')
            load(bgfile); % load bgimgmed0 from contrastadj3.m
        else
            % contrastadj3.m
            [~,bgimgmed0,~]=bgstandard(filelist,simgdir,tissuemaskdir,injmaskdir);
        end
    end
    %% 3. 
    cd(simgdir)
    datainfo.originresolution=datainfo.originresolution*maskscale;
    for f=1:length(filelist)
        [~,filename,~]=fileparts(filelist{f});
        disp(['Processing ',filename,'...'])
        maskfile=[tissuemaskdir,filename,'.tif'];
        if ~exist(maskfile,'file')
            maskfile=[tissuemaskdir,'imgmaskdata_',num2str(f)];
        end
        imgmask=imread(maskfile);
        injmaskfile=[injmaskdir,filename,'.tif'];
        injection_extent(filename,imgmask,bgimgmed0,injcolor,injmaskfile);
        disp([filelist{f},' done.'])
    end
    %     [injdir,~,~]=fileparts(injmaskdir); % remove "/" on the end
    neurondensity=neuronvoxelize(datainfo,tissuemaskdir,injmaskdir,outputdir,1,detecttype);
%     regionneuronsummary(datainfo,detecttype,outputdir,neurondensity,annoimgfile,marmosetlistfile);
end
% delete(poolobj)