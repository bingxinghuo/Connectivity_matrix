motorbraininfo(1).animalid='m820';
motorbraininfo(1).modality='mba';
motorbraininfo(1).signalcolor='r';
motorbraininfo(1).bitinfo=8;
motorbraininfo(1).originresolution=.46*2;
motorbraininfo(1).flips=[]; % rotations needed to orient the annotation to the same as the histology stack
motorbraininfo(2).animalid='m821';
motorbraininfo(2).modality='mba';
motorbraininfo(2).signalcolor='r';
motorbraininfo(2).bitinfo=12;
motorbraininfo(2).originresolution=1.4;
motorbraininfo(2).flips=[1,2];
motorbraininfo(3).animalid='m823';
motorbraininfo(3).modality='mba';
motorbraininfo(3).signalcolor=['g';'r'];
motorbraininfo(3).bitinfo=12;
motorbraininfo(3).originresolution=.46*2;
motorbraininfo(3).flips=[1,2];
motorbraininfo(4).animalid='m852';
motorbraininfo(4).modality='mba';
motorbraininfo(4).signalcolor='g';
motorbraininfo(4).bitinfo=12;
motorbraininfo(4).originresolution=1.4;
motorbraininfo(4).flips=[1,2];
motorbraininfo(5).animalid='m917';
motorbraininfo(5).modality='mba';
motorbraininfo(5).signalcolor='g';
motorbraininfo(5).bitinfo=12;
motorbraininfo(5).originresolution=1.4;
motorbraininfo(5).flips=[1,2];
motorbraininfo(6).animalid='m921';
motorbraininfo(6).modality='mba';
motorbraininfo(6).signalcolor='g';
motorbraininfo(6).bitinfo=12;
motorbraininfo(6).originresolution=1.4;
motorbraininfo(6).flips=[1,2];
motorbraininfo(7).animalid='m1228';
motorbraininfo(7).modality='mba';
motorbraininfo(7).signalcolor='g';
motorbraininfo(7).bitinfo=12;
motorbraininfo(7).originresolution=.46*2;
motorbraininfo(7).flips=[1,2];
parentpath='/Users/bhuo/CSHLservers/mitragpu3/disk125/main/marmosetRIKEN/NZ';
marmosetlistfile='~/Documents/GITHUB/Connectivity_matrix/marmosetregionlist.mat';
targetdir='~/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/MotorCortex/';
%%
for i=2:length(motorbraininfo)
    workpath=[parentpath,'/',motorbraininfo(i).animalid,'/',motorbraininfo(i).animalid,'F/JP2-REG/'];
    cd(workpath)
    for c=1:length(motorbraininfo(i).signalcolor)
        outputdir=[workpath,'/processmask_',motorbraininfo(i).signalcolor(c)];
        if ~exist(outputdir,'dir')
            mkdir(outputdir)
        end
        filelist=jp2lsread;
        signalcolor=motorbraininfo(i).signalcolor(c);
        bitinfo=motorbraininfo(i).bitinfo;
        for f=1:length(filelist)
            disp(['Processing ',filelist{f},'...'])
            signaldet(filelist{f},signalcolor,bitinfo,outputdir);
            disp([filelist{f},' done.'])
        end
        neuronvoxelize(motorbraininfo(i).animalid,'mba',workpath,['/processmask_',motorbraininfo(i).signalcolor(c)],...
            outputdir,motorbraininfo(i).originresolution,80,['process_',motorbraininfo(i).signalcolor(c)],1);
        regionneuronsummary(motorbraininfo(i),targetdir,['process_',motorbraininfo(i).signalcolor(c)],...
            [targetdir,'/',motorbraininfo(i).animalid],marmosetlistfile);
    end
end