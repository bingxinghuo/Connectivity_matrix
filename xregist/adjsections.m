%% adjsections.m
% Bingxing Huo, March 2018
% This function identifies the adjacent fluorescent sections of specified
% Nissl sections
% Inputs:
%   - fludir: directory of all fluorescent JP2 images
%   - nissldir: directory of all Nissl JP2 images
%   - secrangen: a 2-element vector containing the numbers of the first and
%   last Nissl sections of interest. Section number typically is the last 4
%   digits in the file name. e.g. [233,377] (for M919 LGN)
% Outputs:
%   - fileinds_nissl: indices of Nissl sections extracted according to the
%   section numbers
%   - fileinds_flu: indices of fluorescent sections matched to the Nissl
%   sections
function [fileinds_nissl,fileinds_flu]=adjsections(fludir,nissldir,secrangen)
% identify Nissl sections, continuous
cd(nissldir)
nissllist=jp2lsread;
[nind_1,~]=jp2ind(nissllist,num2str(secrangen(1)));
[nind_N,~]=jp2ind(nissllist,num2str(secrangen(2)));
fileinds_nissl=[nind_1:nind_N]';
fileids_nissl=nissllist(nind_1:nind_N); % file names of all the involved Nissl sections
Nfiles=length(fileids_nissl); % number of Nissl sections
% identify adjacent flurescent sections
cd(fludir)
flulist=jp2lsread;
% assign the same number of sections for adjacent fluorescent series
fileinds_flu=zeros(Nfiles,1); % fluorescent file indices corresponding to the Nissl series
for f=1:Nfiles
    fid=fileids_nissl{f}; 
    disp(['Adjacent to ',fid,' is ... '])
    secnum=fid(strfind(fid,'N')+1:strfind(fid,'--')-1); % extract the N* slide number    
    [fileinds_flu(f),fileid_flu]=jp2ind(flulist,['F',secnum]); % get the same F* number
    disp(fileid_flu)
end