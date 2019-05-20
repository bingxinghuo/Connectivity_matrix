% targetdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Paul Martin/';
% datadir='~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/';
% animalid='m822';
% set directory
% animalid=lower(animalid); % in case the input is upper case
% flutifdir=[datadir,animalid,'/',animalid,'F/JP2-REG/',lower(animalid),'F-STIF/'];
% savedir=[targetdir,upper(animalid),'/injection/'];
% if ~exist(savedir,'dir')
%     mkdir(savedir)
% end
% cd(flutifdir)
function inj_maskrgb=injection_extent(fileid,imgmask,bgimgmed0,savefile)
% 1.1 batch downsample on mitragpu3
% ~/scripts/shell_script/convert_jp2_tif_reg.sh m1229 M >/dev/null
tiffile=[fileid,'.tif'];
disp(['Processing ',tiffile,'...'])
fluimg=imread(tiffile);
%% 2. adjust background (bgmean3.m)
% 2.1 Calculate background median
threshmask=fluimg<50; % threshold for forground/backgrond distinction
% threshold background
flubg=fluimg.*cast(threshmask,'like',fluimg);
imgmask1=cast(imgmask,'like',fluimg);
% get tissue
brainimg=flubg.*cat(3,imgmask1,imgmask1,imgmask1);
% calculate median
fluimgpix=cell(3,1);
bgimgmed=zeros(3,1);
for c=1:3
    fluimgpix{c}=nonzeros(brainimg(:,:,c)); % collect all nonzeros pixels
    bgimgmed(c)=median(fluimgpix{c});
end
% 2.2 adjust background
[rows,cols,~]=size(brainimg);
adjmat=ones(rows,cols,3);
adjmat=single(adjmat);
for c=1:3
    adjmat(:,:,c)=adjmat(:,:,c)*(bgimgmed(c)-bgimgmed0(c));
end
fluimg1=single(fluimg)-adjmat;
%% add image mask if missing
%     imgmask=imgmaskgen(fluimg1,1);
%     imwrite(imgmask,maskfile,'tif')
%% 3. threshold to get binary image
if isa(fluimg,'uint16')
    inj_saturergb=fluimg1>=255; % 12-bit data
    %             inj_saturergb(:,:,3)=fluimg1(:,:,3)>=100; % % 920 DY
elseif isa(fluimg,'uint8')
    inj_saturergb=fluimg1>=220; % 8-bit data
end
inj_maskrgb=false(rows,cols,3);
for c=1:3
    if sum(sum(inj_saturergb(:,:,c)))>0
        % FB, blue channel
        inj_sature=inj_saturergb(:,:,c);
        %% 3. image processing
        % 3.1 find the biggest connected component as the injection site
        cc=bwconncomp(inj_sature);
        numPixels = cellfun(@numel,cc.PixelIdxList);
        [biggest,idx] = max(numPixels);
        inj_mask=false(size(inj_sature));
        inj_mask(cc.PixelIdxList{idx})=inj_sature(cc.PixelIdxList{idx});
        % 3.2 adjust the area
        inj_mask=imfill(inj_mask,'holes');% fill holes
        inj_maskrgb(:,:,c)=inj_mask;
    end
end
inj_maskrgb=uint8(inj_maskrgb);
if nargin>3
    imwrite(inj_maskrgb,savefile,'tif')
end
%     GFPmaskfile=['injmasks/GFPmasks/',filelist{f}];
%     GFPmask=cat(3,1-imgmask,1-imgmask,1-imgmask); % white background
%     GFPmask=uint8(GFPmask)*255; % white background 8-bit
%     GFPmask(:,:,2)=GFPmask(:,:,2)+uint8(inj_maskrgb(:,:,2))*255; % green area
%     imwrite(GFPmask,GFPmaskfile,'TIF')
%     FBmaskfile=['injmasks/FBmasks/',filelist{f}];
%     FBmask=cat(3,1-imgmask,1-imgmask,1-imgmask); % white background
%     FBmask=uint8(FBmask)*255; % white background 8-bit
%     FBmask(:,:,3)=FBmask(:,:,3)+uint8(inj_maskrgb(:,:,3))*255; % blue area
%     imwrite(FBmask,FBmaskfile,'tif')
disp('Done')