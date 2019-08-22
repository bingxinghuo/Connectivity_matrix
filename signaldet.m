function signalmask=signaldet(inputfile,signalcolor,bitinfo,outputdir)
inputimg=imread(inputfile);
[h,w,~]=size(inputimg);
signalmask=uint8(zeros(h,w));
if nargin>2
    if isempty(bitinfo)
        bitinfo=12;
    end
else
    bitinfo=12;
end
if bitinfo==12
    inputimg=uint8(inputimg/2^12*2^8); % convert to 8-bit
end
if signalcolor=='g'
    intensity_thresh=80;
    greenmask=inputimg(:,:,2)>(sum(inputimg(:,:,[1,3]),3));
    greenimg=uint8(greenmask).*inputimg(:,:,2);
    signalmask=uint8(greenimg>intensity_thresh);
elseif signalcolor=='r'
    hsvimg=rgb2hsv(inputimg);
    redmask=(hsvimg(:,:,1)>345/346)+(hsvimg(:,:,1)<10/360); % color
    I0=hsvimg(:,:,3)>.03;
    redmask=redmask.*I0; % remove empty areas
    S=(hsvimg(:,:,2)>.3).*I0; % filter saturation
    redmask=redmask.*S;
    redmask=imfill(redmask,'holes');
    redimg=uint8(redmask).*inputimg(:,:,1);
    redfilt=medfilt2(redimg,[5,5]);
    signalmask=uint8(redfilt>0);
end
if nargin>3
    if ~isempty(outputdir)
        [~,filename,~]=fileparts(inputfile);
        imwrite(signalmask,[outputdir,'/',filename,'.tif'])
    end
end
