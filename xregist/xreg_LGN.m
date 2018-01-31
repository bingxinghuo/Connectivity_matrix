%% 1. downsample
% identify flurescent sections
cd(fludir)
filelist=jp2lsread;
[fileind0,~]=jp2ind(filelist,flurange(1));
[fileind1,~]=jp2ind(filelist,flurange(2));
fileinds=fileind0:fileind1;
fileids=filelist(fileind0:fileind1);
flu_files=length(fileids); % number of files
fluorojp2=cell(flu_files,1);
for f=1:flu_files
    fluorojp2{f}=[pwd,'/',fileids{f}];
    maskmat{f}=[pwd,'/imgmasks/imgmaskdata_',num2str(fileinds(f))]; % identify corresponding mask
end
% identify adjacent Nissl sections
cd(nissldir)
filelist=jp2lsread;
[fileind0,~]=jp2ind(filelist,nisslrange(1));
[fileind1,~]=jp2ind(filelist,nisslrange(2));
fileids=filelist(fileind0:fileind1);
nissl_files=length(fileids);
% sanity check
if nissl_files~=flu_files
    error('file numbers do not match!')
end
% continue
nissljp2=cell(nissl_files,1);
for f=1:nissl_files
    nissljp2{f}=[pwd,'/',fileids{f}];
end
%% 2. generate the cell mask

load('imgmasks/imgmaskdata_143.mat')
%%
load('FBdetectdata.mat', 'FBclear')
cellmask=uint8(imgmask);
fbcellind=[round(FBclear{143}.x),round(FBclear{143}.y)];
for i=1:size(fbcellind,1)
    cellmask(fbcellind(i,2),fbcellind(i,1))=10;
end
imwrite(cellmask,'M820-F93_cells.jp2')
%% 3. register fluorescent to Nissl  
xregFluoroToNissl(nissljp2,fluorojp2,transformtxt,celljp2)