function xreg_LGN(animalid,animaldir,secrangef,secrangen)
fludir=[animaldir,'/',animalid,'F/JP2/'];
nissldir=[animaldir,'/',animalid,'N/JP2/'];
workdir=[animaldir,'/',animalid,'F/cellxreg/'];
if ~exist(workdir,'dir')
    mkdir(workdir)
end
% cd(workdir)
%% 1. Get file names
% identify flurescent sections
cd(fludir)
filelist=jp2lsread;
[fileind_1,~]=jp2ind(filelist,num2str(secrangef(1)));
[fileind_N,~]=jp2ind(filelist,num2str(secrangef(2)));
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
[fileind_1,~]=jp2ind(filelist,num2str(secrangen(1)));
[fileind_N,~]=jp2ind(filelist,num2str(secrangen(2)));
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
FBnew=cell(length(FBclear),1);
for f=1:N_flu_files
    % get the image mask
    imgmask=load(maskmat{f});
    maskvar=fieldnames(imgmask);
    imgmask=getfield(imgmask,maskvar{1});
    fbcellind=[round(FBclear{fileinds_flu(f)}.x),round(FBclear{fileinds_flu(f)}.y)];
    cellmask=uint8(imgmask);
    % set index to 10 for cell centroids
    for i=1:size(fbcellind,1)
        cellmask(fbcellind(i,2),fbcellind(i,1))=10;
    end
    celljp2=[workdir,fileids_flu{f}(1:end-4),'_cells.jp2'];
    imwrite(cellmask,celljp2)
    %% 3. register fluorescent to Nissl
    cd(workdir)
    transformtxt=[workdir,fileids_flu{f}(1:end-4),'_trans.txt'];
    xregFluoroToNissl_cell(nissljp2{f},fluorojp2{f},animalid,transformtxt);
    %% 4. transform cell coordinates
    M=64;
    tf=dlmread(transformtxt);
    rotmat=[tf(1),tf(3);tf(2),tf(4)];
    transmat=tf(5:6)*M;
    fbcelltf=rotmat*fbcellind'-transmat*ones(1,size(fbcellind,1));
    % hold on, scatter(fbcelltf(1,:),fbcelltf(2,:),'y*')
    FBnew{fileids_nissl(f)}=fbcelltf';
end
save([workdir,'FBdetect_xreg'],'FBnew')