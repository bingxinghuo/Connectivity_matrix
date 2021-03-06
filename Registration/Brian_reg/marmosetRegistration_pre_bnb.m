function marmosetRegistration_pre_bnb(patientnumber,targetdirectoryprefix,outputtargetfilename,rawmrifilename,outputmrifilename,crop)
% set directories
% patientnumber = 'M920';
% targetdirectoryprefix = '/sonas-hc/mitra/hpc/home/blee/data/target_images/';
% outputtargetfilename = [targetdirectoryprefix patientnumber '/' patientnumber '_80_cropped'];
% rawmrifilename = [targetdirectoryprefix patientnumber '/20160528_21095708DTI128axb1000news180001a001.nii'];
% outputmrifilename = [targetdirectoryprefix patientnumber '/' patientnumber '_mri_200'];

%%
addpath ./nii
modalities = ['N','F','M','C'];
for ii = 1:length(modalities)

    directoryname = [targetdirectoryprefix patientnumber '/' patientnumber modalities(ii) '-RTIF/'];
    directory = dir(directoryname);
    slicenumbers = [];
    adr = natsortfiles({directory(4:end).name});
    uind1 = regexp(adr{1},modalities(ii));
    uind2 = regexp(adr{1},'--');
    slidenum = str2num(adr{1}(uind1(end)+1:uind2-1));
    slidepos = str2num(adr{1}(uind2+3));

    firstslicenumber = (slidenum-1)*2+slidepos;
    for i = 1:size(adr,2)
        uind1 = regexp(adr{i},modalities(ii));
        uind2 = regexp(adr{i},'--');
        slidenum = str2num(adr{i}(uind1(end)+1:uind2(end)-1));
        % for m820 only
        %slidepos = str2num(directory(i).name(uind2+3))-1;
        slidepos = str2num(adr{i}(uind2(end)+3));
        if i == 1
            lastslidenum = slidenum;
            lastslidepos = slidepos;
            slicenumbers = [slicenumbers firstslicenumber];
            continue
        end
        if lastslidenum == slidenum
            slicenumbers = [slicenumbers, slicenumbers(end) + 1];
        else
            % m983
            %if slidenum < 149 || slidenum > 225
            % m919new
            %if slidenum < 77 || slidenum > 120
            % m820new
            %if slidenum < 51 || slidenum > 200
            % m920
            if slidenum < 73 || slidenum > 218
                slicenumbers = [slicenumbers, slicenumbers(end) + (slidenum - lastslidenum-1)*2 + (slidepos-lastslidepos+2)];
            else
                slicenumbers = [slicenumbers, slicenumbers(end) + (slidenum - lastslidenum-1)*1 + 1];
            end
        end
        lastslidenum = slidenum;
        lastslidepos = slidepos;
    end
    if strcmp(modalities(ii),'N')
        nslicenumbers = slicenumbers;
    elseif strcmp(modalities(ii),'F')
        fslicenumbers = slicenumbers;
    elseif strcmp(modalities(ii),'M')
        mslicenumbers = slicenumbers;
    elseif strcmp(modalities(ii),'C')
        cslicenumbers = slicenumbers;
    end
end

minslicenumber = min([nslicenumbers(1),fslicenumbers(1),mslicenumbers(1),cslicenumbers(1)]);
maxslicenumber = max([nslicenumbers(end),fslicenumbers(end),mslicenumbers(end),cslicenumbers(end)]);
nslices = maxslicenumber - minslicenumber + 1;

originalpixelsize = [0.46*128/1000 0.08 0.46*128/1000];
newpixelsize = [0.08 0.08 0.08];

factor = 4; % pick a factor of the pixel ratio for your kernel width/height
kernelsize_x = round(newpixelsize(1)/originalpixelsize(1)*factor); %select the kernel width/height (not the gaussian radius), I usually make it a few times bigger than the pixel ratio
kernelsize_y = round(newpixelsize(3)/originalpixelsize(3)*factor);
if ~mod(kernelsize_x,2)
    kernelsize_x = kernelsize_x+1;
end
if ~mod(kernelsize_y,2)
    kernelsize_y = kernelsize_y+1;
end
kernel = zeros(kernelsize_x,kernelsize_y);
kernelcenter_x = ceil(kernelsize_x/2);
kernelcenter_y = ceil(kernelsize_y/2);

sigma_x = newpixelsize(1)/originalpixelsize(1)/4;
sigma_y = newpixelsize(3)/originalpixelsize(3)/4;

% populate kernel with 2d gaussian
for i = 1:kernelsize_x
    for ii = 1:kernelsize_y
        kernel(i,ii) = exp(-1*((i-kernelcenter_x)^2/(2*sigma_x^2) + (ii-kernelcenter_y)^2/(2*sigma_y^2)));
    end
end

% normalize the kernel
kernel = kernel./(sum(sum(kernel)));

% load the first nissl image
directoryname = [targetdirectoryprefix patientnumber '/' patientnumber 'N-RTIF/'];
directory = dir(directoryname);
adr = natsortfiles({directory(4:end).name});

img = rgb2gray(imread([directoryname adr{1}]));

[meshx,meshy] = meshgrid(1:newpixelsize(3)/originalpixelsize(3):size(img,2),1:newpixelsize(1)/originalpixelsize(1):size(img,1));

newimg = ones(size(meshx,1), nslices , size(meshx,2))*255;
for i = 1:length(nslicenumbers)
    img = rgb2gray(imread([directoryname adr{i}]));
    bgval = img(1,1);
    newslice = conv2(double(img), double(kernel), 'same');
    newslice_interp = interp2(newslice, meshx, meshy);
    newimg(:,nslicenumbers(i)-minslicenumber+1,:) = newslice_interp;    
    newimg(1,nslicenumbers(i)-minslicenumber+1,:) = bgval;
    newimg(end,nslicenumbers(i)-minslicenumber+1,:) = bgval;
    newimg(:,nslicenumbers(i)-minslicenumber+1,1) = bgval;
    newimg(:,nslicenumbers(i)-minslicenumber+1,end) = bgval;
end

% analyze format
outimg = make_blank_img();
outimg.img = newimg;
outimg.hdr.dime.dim(2:4) = size(newimg);
outimg.hdr.dime.pixdim(2:4) = newpixelsize;
outimg.hdr.dime.datatype = 16;
outimg.hdr.dime.bitpix = 16;
outimg.fileprefix = '';
%avw_img_write(outimg,outimg.fileprefix)

% crop the image because it's way too big
%newimg([1:100, 383:end],:,:) = [];
%newimg(:,:,[1:137, 416:end]) = [];
newimg([1:crop(1), crop(2):end],:,:) = [];
newimg(:,:,[1:crop(3), crop(4):end]) = [];
newimg = -1*newimg + 255;
outimg = make_blank_img();
outimg.img = newimg;
outimg.hdr.dime.dim(2:4) = size(newimg);
outimg.hdr.dime.pixdim(2:4) = newpixelsize;
outimg.hdr.dime.datatype = 16;
outimg.hdr.dime.bitpix = 16;
outimg.fileprefix = outputtargetfilename;
avw_img_write(outimg,outimg.fileprefix)




% now do the mri
mri = load_untouch_nii(rawmrifilename);
mrivol = mri.img(:,:,:,1);
mrivol_rot = zeros(105,190,190);
for i = 1:size(mrivol,2)
    mrivol_rot(:,i,:) = rot90(squeeze(mrivol(:,i,:)));
end
% scale to 255
mrivol_rot = mrivol_rot./max(max(max(mrivol_rot))).*255;

mriout = make_blank_img();
mriout.hdr.dime.dim(2:4) = size(mrivol_rot);
mriout.hdr.dime.pixdim(2:4) = mri.hdr.dime.pixdim(2:4);
mriout.hdr.dime.glmax = 255;
mriout.fileprefix = outputmrifilename;
mriout.img = mrivol_rot;
mriout.hdr.dime.bitpix = 16;
mriout.hdr.dime.datatype = 16;
avw_img_write(mriout,mriout.fileprefix);



