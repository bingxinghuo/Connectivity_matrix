motorbraininfo(1).animalid='m820';
motorbraininfo(1).signalcolor='r';
motorbraininfo(1).bitinfo=8;
motorbraininfo(2).animalid='m821';
motorbraininfo(2).signalcolor='r';
motorbraininfo(2).bitinfo=12;
motorbraininfo(3).animalid='m823';
motorbraininfo(3).signalcolor=['g';'r'];
motorbraininfo(3).bitinfo=12;
parentpath='/Users/bhuo/CSHLservers/mitragpu3/disk125/main/marmosetRIKEN/NZ';
for i=1:length(motorbraininfo)
    workpath=[parentpath,'/',motorbraininfo(i).animalid,'/',motorbraininfo(i).animalid,'F/JP2-REG/'];
    cd(workpath)
    for c=1:length(motorbraininfo(i).signalcolor)
        outputdir=[workpath,'/processmask_',motorbraininfo(i).signalcolor];
        if ~exist(outputdir,'dir')
            mkdir(outputdir)
        end
        filelist=jp2lsread;
        signalcolor=motorbraininfo(i).signalcolor;
        bitinfo=motorbraininfo(i).bitinfo;
        for f=1:length(filelist)
            disp(['Processing ',filelist{f},'...'])
            signaldet(filelist{f},signalcolor,bitinfo,outputdir);
            disp([filelist{f},' done.'])
        end
    end
end