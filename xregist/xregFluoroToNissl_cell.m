%% xregFluoroToNissl_cell.m
% Bingxing Huo, March 2018
% This function performs rigid transformation from Nissl to its neighboring fluorescent image
% Inputs:
%   - nissljp2: a string containing the jp2 file of the Nissl section
%   - fluorojp2: a string containing the jp2 file of the Nissl section
% Outputs are directly saved in the directory, including:
%   - the transformation matrix saved in text format
%   - if downsampled tif files for either fluorescent or Nissl series do
%   not exist, generate 64X downsampled small tifs and save them
function xregFluoroToNissl_cell(nissljp2,fluorojp2,animalid,transformtxt)
% M=64;
%% 1. Read in small tifs
% 1.1 Nissl
updirind=strfind(nissljp2,'/');
ntifdir=[nissljp2(1:updirind(end-1)),upper(animalid),'N-STIF/'];
if exist(ntifdir,'dir')
    nissltif=[ntifdir,nissljp2(updirind(end)+1:end-4),'.tif'];
    if ~exist(nissltif,'file')
        error('Missing Nissl downsampled tiff file!')
        %         % load
        %         nisslimg=imread(nissljp2,'jp2');
        %         [nisslheight,nisslwidth,~]=size(nisslimg);
        %         % downsample
        %         for i=1:3
        %             nisslsmall(:,:,i)=downsample_max(nisslimg(:,:,i),M);
        %         end
        %         % save
        %         imwrite(nisslsmall,nissltif,'tif','compression','lzw')
        %     else
    end
    imgsize=imfinfo(nissljp2);
    nisslwidth=imgsize.Width;
    nisslheight=imgsize.Height;
end
% 1.2 Fluorescent image
updirind=strfind(fluorojp2,'/');
ftifdir=[fluorojp2(1:updirind(end-1)),upper(animalid),'F-STIF/'];
if exist(ftifdir,'dir')
    fluorotif=[ftifdir,fluorojp2(updirind(end)+1:end-4),'.tif'];
    if ~exist(fluorotif,'file')
        error('Missing fluorescent downsampled tiff file!')
        %     if ~exist(fluorotif,'file')
        %         % load
        %         fluoroimg=imread(fluorojp2,'jp2');
        %         % downsample
        %         for i=1:3
        %             fluorosmall(:,:,i)=downsample_max(fluoroimg(:,:,i),M);
        %         end
        %         % save
        %         imwrite(fluorosmall,fluorotif,'tif','compression','lzw')
        %     end
    end
    % 1.3 transformed fluorescent images
    xregFdir=['../xregF/'];
    if ~exist(xregFdir,'dir')
        mkdir(xregFdir)
    end
    fluorotif_deformed=[xregFdir,fluorojp2(updirind(end)+1:end-4),'.tif'];
end
%% 2. Python code to generate the transformation matrix
status=system(['python ~/scripts/Connectivity_matrix/xregist/rigidFluoroToNissl_cellmask.py ',...
    nissltif,' ',fluorotif,' ',fluorotif_deformed,' ',transformtxt]);