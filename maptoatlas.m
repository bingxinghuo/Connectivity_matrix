function imgatlasmap=maptoatlas(imglist,annoimgs,originres,dsrate,annores,seclist)
[H1,N1,W1]=size(annoimgs);
conversion_factor=round(annores/originres);
imgatlasmap=cell(length(imglist),3);
for i=1:length(imglist)
    disp(['Processing ',imglist{i},'...'])
    annomap=squeeze(annoimgs(:,N1-40-seclist(i)+1,:)); % 40 anterior padding
    annomap=flip(annomap,1);
    img=imread(imglist{i}); % read the image
    C=size(img,3);
    for c=1:C
        imgatlasmap{i,c}=single(zeros(size(annomap)));
        ifempty=sum(sum(img(:,:,c)));
        if ifempty>0
            imgmask_up=repelem(img(:,:,c),dsrate,dsrate);
            imgmask_match=downsample_max(imgmask_up,conversion_factor,conversion_factor); % matched to annotation map resolution
            imgmask_match=single(imgmask_match(1:H1,1:W1));
            imgatlasmap{i,c}=annomap.*imgmask_match;
        end
    end
    disp('Done.')
end