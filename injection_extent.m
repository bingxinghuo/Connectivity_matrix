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
function inj_maskrgb=injection_extent(fileid,imgmask,bgimgmed0,injcolor,savefile)
% 1.1 batch downsample on mitragpu3
% ~/scripts/shell_script/convert_jp2_tif_reg.sh m1229 M >/dev/null
tiffile=[fileid,'.tif'];
% disp(['Processing ',tiffile,'...'])
fluimg=imread(tiffile);
if isa(fluimg,'uint16')
    bitinfo=12;
elseif isa(fluimg,'uint8')
    bitinfo=8;
    
end
% signalmaskrgb=signaldet(fluimg,injcolor,imgmask,bgimgmed0,bitinfo);
fluimg1=bgadj(fluimg,imgmask,bgimgmed0); % adjust background
if bitinfo==12
    fluimg1=fluimg1*(2^16/2^12); % scale to full 16-bit
    threshmask=50*(2^4);
elseif bitinfo==8
    threshmask=50;
end
hsvimg=rgb2hsv(cast(fluimg1,'like',fluimg));
I1=hsvimg(:,:,3)>nanmean(nonzeros(hsvimg(:,:,3)))+nanstd(nonzeros(hsvimg(:,:,3)));
S1=hsvimg(:,:,2)>nanmean(nonzeros(hsvimg(:,:,2)))+nanstd(nonzeros(hsvimg(:,:,2)));
inj_maskrgb=false(size(fluimg));
for c=injcolor
    injmask=(fluimg1(:,:,c)>threshmask).*I1.*S1;
    if sum(sum(injmask))>0
        % find the biggest connected component as the injection site
        cc=bwconncomp(injmask);
        numPixels = cellfun(@numel,cc.PixelIdxList);
        [biggest,idx] = max(numPixels);
        injmask1=false(size(injmask));
        injmask1(cc.PixelIdxList{idx})=injmask(cc.PixelIdxList{idx});
        % 3.2 adjust the area
        injmask=imfill(injmask1,'holes');% fill holes
        inj_maskrgb(:,:,c)=injmask;
    end
end
inj_maskrgb=uint8(inj_maskrgb*255);
if nargin>4
    imwrite(inj_maskrgb,savefile,'tif')
end
disp('Done')