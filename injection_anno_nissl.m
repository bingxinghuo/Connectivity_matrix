% Nissl + injection + annotation
%% 1. Gathering ingredients
% 1.1 generate small Nissl REG
% ~/scripts/shell_script/convert_jp2_tif_reg.sh m1146 N >/dev/null
% section correspondence
fid=fopen('M1146F_F_anno_seclist.csv'); % output from F_REG_secnum.py
seclist=textscan(fid,'%q %u','Delimiter',',');
fclose(fid);
%%
nissllist=jp2lsread;
nisslimg=imread(nissllist{376});
[rows,cols,~]=size(nisslimg);
%% 1.2 Get annotation
annostack=load_nii('M1146_annotation.img');
rangeofinterest=325:375;
%%
for r=length(rangeofinterest)
    secnum=seclist{2}(rangeofinterest(r))+40;
    annoimg=squeeze(annostack.img(:,end-secnum+1,:));
    annoimg(annoimg>=10000)=annoimg(annoimg>=10000)-10000;
    annoimg1=label2rgb(annoimg,'jet','k');
    annoimg1=flipdim(annoimg1,1); % flip upside down
    annoimg1=repelem(annoimg1,87,87);
    annoimg1=annoimg1(1:rows,1:cols,:);
    
end
imgcomp1=nisslimg+annoimg1;
%% 1.3 Get injection masks
M=64;
f=375;
injmask=imread(['injmaskdata_',num2str(f)]);
% injmaskexp=repelem(injmask,M,M);
injedge=edge(injmask(:,:,3));
injedgexp=repelem(injedge,M,M);
injedgexp=cat(3,injedgexp,injedgexp,injedgexp);
%

% injmaskexp=injmaskexp(1:rows,1:cols,:);
% injmaskexp=imgaussfilt(uint8(injmaskexp*255),1);
injedgexp=injedgexp(1:rows,1:cols,:);
injedgexp=imgaussfilt(uint8(injedgexp),1);
imgcomp1=imgcomp1.*(1-injedgexp);
%%
imgcomp2=nisslimg.*(1-injedgexp);