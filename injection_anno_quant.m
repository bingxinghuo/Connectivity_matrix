%% quantitatve injection annotation
targetdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Paul Martin/';
datadir='~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/';
animalid='m822';
% set directory
animalid=lower(animalid); % in case the input is upper case
flutifdir=[datadir,animalid,'/',animalid,'F/JP2-REG/',lower(animalid),'F-STIF/'];
savedir=[targetdir,upper(animalid),'/injection/'];
if ~exist(savedir,'dir')
    mkdir(savedir)
end
if ~exist(flutifdir,'dir')
    disp('Please generate small tif for registered images first!')
    disp(['Run following code on mitragpu3: ~/scripts/shell_script/convert_jp2_tif_reg.sh ', animalid,' F >/dev/null'])
end
cd(flutifdir)
filelist=filelsread('*.tif');
%%

% rangeofinterest=325:375; bit=12;% 1146
% rangeofinterest=239:377; bit=12;% 1144
% rangeofinterest=256:342; bit=12;% 920 Note: don't include FB
% rangeofinterest=269:331; bit=12;% 1147
% rangeofinterest=288:313; bit=12;% 1148
% rangeofinterest=197:269; bit=12;% 919
rangeofinterest=289:399; bit=8; % 822
% rangeofinterest=243:300; bit=8; % 820
%% injection_extent.m
injmaskfile=[savedir,'/injmaskstack.tiff'];
if ~exist(injmaskfile,'file')
    injection_extent
end
sizeinfo=imfinfo(injmaskfile);
H=sizeinfo(1).Height;
W=sizeinfo(1).Width;
C=3;
N=length(sizeinfo);
%% 3D overlay
% get 3D reconstruction of annotation
% load annotation
annostack=load_nii([targetdir,upper(animalid),'/',animalid,'_annotation.img']);
annoimgs=annostack.img;
annoimgs(annoimgs>=10000)=annoimgs(annoimgs>=10000)-10000; % adjust LR hemisphere difference
[H1,N1,W1]=size(annoimgs);
% load correspondence
seclistfile=[savedir,'../',upper(animalid),'F_anno_seclist.csv'];
if ~exist(seclistfile,'file')
    disp('Please establish section correspondence by running F_REG_secnum.py! ')
    %%%% run F_REG_secnum.py in shell
    % ANIMALID=822
    % python F_REG_secnum.py M$ANIMALID F ~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/m$ANIMALID/m$ANIMALID"F"/JP2-REG/m$ANIMALID"F-STIF" ~/"Dropbox (Marmoset)"/BingxingHuo/"Marmoset Brain Architecture"/"Paul Martin"/M$ANIMALID 91 190
    %%%%
end
fid=fopen(seclistfile); % output from F_REG_secnum.py
seclist=textscan(fid,'%q %u','Delimiter',',');
fclose(fid);
%%
% get 3D reconstruction of injection mask
% injection_extent.m
injstack1=uint8(zeros(H,W,C,N1));
for f=rangeofinterest
    % fix saturation in 8-bit images
    if bit==8
        tifimg= imread(injmaskfile,f-rangeofinterest(1)+1);
        tifmono=sum(tifimg,3);
        tifmask=uint8(1-(tifmono>1));
        tifimg1=tifimg.*cat(3,tifmask,tifmask,uint8(ones(size(tifmask))));
        injstack1(:,:,:,42+seclist{2}(f))=tifimg1;
    elseif bit==12
        injstack1(:,:,:,42+seclist{2}(f))=imread(injmaskfile,f-rangeofinterest(1)+1);
    end
end
%% get injection mask with annotated region ID
% conversion_factor=round(80/(.46*3)); %920
conversion_factor=round(80/(.46*2));
injannostack=zeros(H,W,C,length(rangeofinterest));
for f=rangeofinterest
    display([num2str(f-rangeofinterest(1)+1),'/',num2str(length(rangeofinterest))]);
    tic
    secnum=42+seclist{2}(f);
    injmaskimg=single(injstack1(:,:,:,secnum));
    if sum(sum(sum(injmaskimg)))>0
        if bit==12
            annoimg=squeeze(annoimgs(:,end-secnum+1,:)); % get corresponding slice
            annoimg=flip(annoimg); % fix orientation
        elseif bit==8
            annoimg=squeeze(annoimgs(:,secnum,:)); % 8-bit data
        end
        
        annoimg1=repelem(annoimg,conversion_factor,conversion_factor); % match dimension
        annoimg2=downsample_max(annoimg1,64,64);
        annoimg2=annoimg2(1:H,1:W);
        %
        annoimg2_3D=cat(3,annoimg2,annoimg2,annoimg2);
        injannoimg=injmaskimg.*annoimg2_3D;
        % manual fix for missed annotation
        for c=3
            if sum(sum(injmaskimg(:,:,c)))>sum(sum(injannoimg(:,:,c)))
                h=imoverlay(uint8(annoimg2_3D),injmaskimg(:,:,c));
                figure, ax1=subplot(1,3,1); imagesc(h)
                ax2=subplot(1,3,2); imagesc(annoimg2)
                ax3=subplot(1,3,3); imagesc(injmaskimg)
                linkaxes([ax1,ax2,ax3])
                manual_regid=input('Please manually identify the region id: ');
                injannoimg(:,:,c)=injannoimg(:,:,c)+injmaskimg(:,:,c).*(annoimg2==0)*manual_regid;
                close
            end
        end
        injannostack(:,:,:,f)=injannoimg;
    end
    toc
end
%%
voxsize=(.46*2*64)^2*80/1e+9;
% voxsize=(.46*3*64)^2*80/1e+9; % 920
injvols=squeeze(sum(sum(sum(injannostack>0,1),2),4))*voxsize
%%
save([savedir,'annotated_injections'],'injannostack','injvols')