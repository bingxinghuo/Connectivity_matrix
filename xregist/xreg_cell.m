%% xreg_cell.m
% Bingxing Huo, March 2018
% This function transforms the cell centroid coordinates for each
% fluorescent section to cross register with its adjacent Nissl section
% Inputs:
%   - animalid: a string containing the ID of the animal. e.g. 'm919'
%   - animaldir: the directory containing all series images of the animal
%   e.g. '~/marmosetRIKEN/NZ/m919/'
%   - secrangen: a 2-element vector containing the numbers of the first and
%   last Nissl sections of interest. Section number typically is the last 4
%   digits in the file name. e.g. [233,377] (for M919 LGN)
% Outputs are directly saved in the directory, including:
%   - a JP2 image containing the section mask and cell centroids
%   - if downsampled tif files for either fluorescent or Nissl series do
%   not exist, generate 64X downsampled small tifs and save them
%   - a transformation matrix saved in text file
%   - All transformed FB cell counting for each Nissl section saved in
%   FBdetect_xreg.mat, along with its corresponding fluorescent and Nissl
%   section indices. 
function xreg_cell(animalid,animaldir,secrangen)
animalid=lower(animalid); % in case the input is upper case
fludir=[animaldir,'/',animalid,'F/JP2/'];
nissldir=[animaldir,'/',animalid,'N/JP2/'];
workdir=[animaldir,'/',animalid,'F/cellxreg/'];
if ~exist(workdir,'dir')
    mkdir(workdir)
end
% cd(workdir)
%% 1. Identify the Nissl and corresponding fluorescent sections of interest
[fileinds_nissl,fileinds_flu]=adjsections(fludir,nissldir,secrangen);
% identify Nissl sections
cd(nissldir)
nissllist=jp2lsread;
Nfiles=length(fileinds_nissl); % number of Nissl sections
% generate individual file path for Nissl sections
nissljp2=cell(Nfiles,1);
for n=1:Nfiles
    nissljp2{n}=[pwd,'/',nissllist{fileinds_nissl(n)}];
end
% Identify the corresponding fluorescent sections with their masks
cd(fludir)
flulist=jp2lsread;
Nfiles=length(fileinds_flu); % number of fluorescent sections
fluorojp2=cell(Nfiles,1);
maskmat=cell(Nfiles,1);
for n=1:Nfiles
    fluorojp2{n}=[pwd,'/',flulist{fileinds_flu(n)}]; % generate individual file path for fluorescent sections
    maskmat{n}=[pwd,'/imgmasks/imgmaskdata_',num2str(fileinds_flu(n))]; % identify corresponding mask
end
%% 2. generate the cell mask from fluorescent series
cd(fludir)
load('FBdetectdata.mat', 'FBclear')
FBnissl=cell(length(nissllist),1); % FB cell counting matched to individual nissl sections
for n=1:Nfiles
    fluid=flulist{fileinds_flu(n)};
    disp(['Processing ',fluid,'...(',num2str(n),'/',num2str(Nfiles),')'])
    % get the image mask
    celljp2=[workdir,fluid(1:end-4),'_cells.jp2'];
    if ~exist(celljp2,'file')
        imgmask=load(maskmat{n});
        maskvar=fieldnames(imgmask);
        imgmask=getfield(imgmask,maskvar{1});
        cellmask=uint8(imgmask);
        fbcellind=[round(FBclear{fileinds_flu(n)}.x),round(FBclear{fileinds_flu(n)}.y)];
        % set index to 10 for cell centroids
        for i=1:size(fbcellind,1)
            cellmask(fbcellind(i,2),fbcellind(i,1))=10;
        end
        % save this mask as a jp2 file
        imwrite(cellmask,celljp2)
    else
        fbcellind=[round(FBclear{fileinds_flu(n)}.x),round(FBclear{fileinds_flu(n)}.y)];
    end
    %% 3. register fluorescent to Nissl
    cd(workdir)
    transformtxt=[workdir,fluid(1:end-4),'_trans.txt'];
    if ~exist(transformtxt,'file')
        xregFluoroToNissl_cell(nissljp2{n},fluorojp2{n},animalid,transformtxt);
    end
    %% 4. transform cell coordinates
    M=64;
    tf=dlmread(transformtxt);
    rotmat=[tf(1),tf(3);tf(2),tf(4)]; % rotation
    transmat=tf(5:6)*M; % translation
    % transform all cell coordinates
    fbcelltf=rotmat*fbcellind'-transmat*ones(1,size(fbcellind,1));
    % hold on, scatter(fbcelltf(1,:),fbcelltf(2,:),'y*')
    %% 5. save cell coordinates for each Nissl section
    FBnissl{fileinds_nissl(n)}=fbcelltf';
end
save([workdir,'FBdetect_xreg'],'FBnissl','fileinds_flu','fileinds_nissl')