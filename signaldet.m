function signalmask=signaldet(inputfile,signalcolor,bitinfo,outputdir)
inputimg=imread(inputfile);
if nargin>2
    if isempty(bitinfo)
        bitinfo=12;
    end
else
    bitinfo=12;
end
if bitinfo==12
    inputimg=uint16(inputimg*(2^16/2^12)); % scale to full 16-bit
end
hsvimg=rgb2hsv(inputimg);
if signalcolor=='g'
    c=2;
    H0=(hsvimg(:,:,1)<150/360).*(hsvimg(:,:,1)>80/360); % green color
    
elseif signalcolor=='r'
    c=1;
    H0=(hsvimg(:,:,1)>(345/360))+(hsvimg(:,:,1)<(10/360)); % color
end
I0=hsvimg(:,:,3)>nanmean(nonzeros(hsvimg(:,:,3)));
S0=hsvimg(:,:,2)>nanmean(nonzeros(hsvimg(:,:,2)));
signalmask=H0.*I0.*S0;
signalmask=imfill(signalmask,'holes');
signalimg=cast(signalmask,'like',inputimg).*inputimg(:,:,c);
signalfilt=medfilt2(signalimg,[5,5]);
signalmask=uint8(signalfilt>0);
if nargin>3
    if ~isempty(outputdir)
        [~,filename,~]=fileparts(inputfile);
        imwrite(signalmask,[outputdir,'/',filename,'.tif'])
    end
end
