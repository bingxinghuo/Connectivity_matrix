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
motorbraininfo(2).originresolution=.46*2;
motorbraininfo(2).flips=[1,2];
motorbraininfo(3).animalid='m823';
motorbraininfo(3).modality='mba';
motorbraininfo(3).signalcolor=['g';'r'];
motorbraininfo(3).bitinfo=12;
motorbraininfo(3).originresolution=.46*2;
motorbraininfo(3).flips=[1,2];
parentpath='/Users/bhuo/CSHLservers/mitragpu3/disk125/main/marmosetRIKEN/NZ';
%%
for i=3:length(motorbraininfo)
    workpath=[parentpath,'/',motorbraininfo(i).animalid,'/',motorbraininfo(i).animalid,'F/JP2-REG/'];
    cd(workpath)
    for c=2:length(motorbraininfo(i).signalcolor)
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
    end
end