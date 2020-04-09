function signalmaskrgb=signaldet(inputimg,signalcolor,imgmask,bgimgmed0,bitinfo,signalmaskfile)
if isa(inputimg,'char')
    inputimg=imread(inputimg);
end
[rowi,coli,~]=size(inputimg);
if isa(imgmask,'char')
    imgmask=imread(imgmask);
end
[rowm,colm]=size(imgmask);
if rowi~=rowm
    M=[ceil(rowi/rowm),ceil(coli/colm)];
    imgmask1=repelem(imgmask,M(1),M(2));
    imgmask=imgmask1(1:rowi,1:coli);
end
imgmask=cast(imgmask,'like',inputimg);
%% 1. preprocess
bgu=unique(bgimgmed0);
if length(bgu)==1 && bgu(1)==0
    fluimg1=inputimg.*imgmask;
else
    fluimg1=bgadj(inputimg,imgmask,bgimgmed0); % adjust background
end
if nargin>4
    if isempty(bitinfo)
        bitinfo=12;
    end
else
    bitinfo=12;
end
if bitinfo==12
    fluimg1=fluimg1*(2^16/2^12); % scale to full 16-bit
end
%%
signalmaskrgb=uint8(zeros(size(inputimg)));
hsvimg=rgb2hsv(cast(fluimg1,'like',inputimg));
for sc=1:length(signalcolor)
    c=double(signalcolor(sc));
    if c==2
        H1=(hsvimg(:,:,1)<150/360).*(hsvimg(:,:,1)>80/360); % green color
    elseif c==1
        H1=(hsvimg(:,:,1)>(345/360))+(hsvimg(:,:,1)<(10/360)); % color
    elseif c==3
        H1=(hsvimg(:,:,1)<300/360).*(hsvimg(:,:,1)>180/360); % blue color
    end
    I1=hsvimg(:,:,3)>nanmean(nonzeros(hsvimg(:,:,3).*H1));
    S1=hsvimg(:,:,2)>nanmean(nonzeros(hsvimg(:,:,2).*H1));
    signalmask=H1.*I1.*S1;
    signalmask=imfill(signalmask,'holes');
    signalmask=cast(signalmask,'like',fluimg1);
    signalimg=signalmask.*fluimg1(:,:,c);
    signalfilt=medfilt2(signalimg,[5,5]);
    signalmask=uint8(signalfilt>0);
    signalmaskrgb(:,:,c)=signalmask;
end
%%
if nargin>5
    if ~isempty(signalmaskfile)
        imwrite(signalmaskrgb,signalmaskfile)
    end
end
