function xreg_LGN(workdir,fludir,nissldir,secrange)
cd(workdir)
%% 1. downsample
% identify flurescent sections
cd(fludir)
filelist=jp2lsread;
[fileind_1,~]=jp2ind(filelist,num2str(secrange(1)));
[fileind_N,~]=jp2ind(filelist,num2str(secrange(2)));
fileinds_flu=fileind_1:fileind_N; % file indices of all the involved fluorescent sections
fileids_flu=filelist(fileind_1:fileind_N); % file names of all the involved fluorescent sections
N_flu_files=length(fileids_flu); % number of fluorescent sections
fluorojp2=cell(N_flu_files,1);
maskmat=cell(N_flu_files,1);
for f=1:N_flu_files
    fluorojp2{f}=[pwd,'/',fileids_flu{f}]; % generate individual file path for fluorescent sections
    maskmat{f}=[pwd,'/imgmasks/imgmaskdata_',num2str(fileinds_flu(f))]; % identify corresponding mask
end
% identify adjacent Nissl sections
cd(nissldir)
filelist=jp2lsread;
[fileind_1,~]=jp2ind(filelist,num2str(secrange(1)));
[fileind_N,~]=jp2ind(filelist,num2str(secrange(2)));
fileids_nissl=filelist(fileind_1:fileind_N); % file names of all the involved Nissl sections
N_nissl_files=length(fileids_nissl); % number of Nissl sections
% sanity check
if N_nissl_files~=N_flu_files
    error('file numbers do not match!') % must be the same number of sections in two series
end
% generate individual file path for Nissl sections
nissljp2=cell(N_nissl_files,1);
for f=1:N_nissl_files
    nissljp2{f}=[pwd,'/',fileids_nissl{f}];
end
%% 2. generate the cell mask
cd(fludir)
load('FBdetectdata.mat', 'FBclear')
for f=1:N_flu_files
    imgmask=load(maskmat{f});
    maskvar=fieldnames(imgmask);
    imgmask=getfield(imgmask,maskvar{1});
    fbcellind=[round(FBclear{fileinds_flu(f)}.x),round(FBclear{fileinds_flu(f)}.y)];
    cellmask=uint8(imgmask);
    for i=1:size(fbcellind,1)
        cellmask(fbcellind(i,2),fbcellind(i,1))=10;
    end
    imwrite(cellmask,[workdir,fluorojp2{f}(1:end-4),'_cells.jp2'])
    transformtxt=[workdir,fluorojp2{f}(1:end-4),'_trans.txt'];
    celljp2=[workdir,fluorojp2{f}(1:end-4),'_cells_deformed.jp2'];
    %% 3. register fluorescent to Nissl
    cd(workdir)
    xregFluoroToNissl(nissljp2,fluorojp2,transformtxt,celljp2,64);
end