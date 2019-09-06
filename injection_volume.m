%% parameter
% clear all
animalid='m820';
bit=8;
%% load data
targetdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Paul Martin/';
% set directory
savedir=[targetdir,upper(animalid),'/injection/'];
stackfile=[savedir,'/injmaskstack.tiff'];
stackinfo=imfinfo(stackfile);
W=stackinfo(1).Width;
H=stackinfo(1).Height;
C=3;
N1=length(stackinfo);
injstack=uint8(zeros(H,W,C,N1));
for f=1:N1
    injstack(:,:,:,f)=imread(stackfile,f);
end
if bit==8
    % for 8-bit data with saturation
    injstack2=uint8(zeros(size(injstack)));
    for f=1:N1
        tifimg=squeeze(injstack(:,:,:,f));
        tifmono=sum(tifimg,3);
        tifmask=uint8(1-(tifmono>1));
        tifimg1=tifimg.*cat(3,tifmask,tifmask,uint8(ones(size(tifmask))));
        injstack2(:,:,:,f)=tifimg1;
    end
elseif bit==12
    injstack2=injstack;
end
%%
voxsize=(.46*2*64)^2*80/1e+9;
injvols=squeeze(sum(sum(sum(injstack2,1),2),4))*voxsize
%%
save([savedir,'/injvolsdata'],'injvols')