function signalmap_anno=maptoatlas(imglist,annoimgs,seclist,originres,dsrate,annores,outputfile)
[H1,N1,W1]=size(annoimgs);
% check if resample is needed
toresample=1; % default to resample
if nargin==3
    toresample=0;
else
    if isempty(originres) || isempty(annores) || isempty(dsrate)
        toresample=0;
    else
        conversion_factor=round(annores/originres);
        if conversion_factor==dsrate
            toresample=0; % don't do if they are the same
        end
    end
end
% load images
L=size(imglist,1);
if isa(imglist,'char') % guess it is a virtual stack file name
    S=imfinfo(imglist);
    filenames={S(:).Filename};
    L=length(filenames);
    img=cell(L,1);
    for i=1:L
        %         disp(['Processing ',filenames{i},'...'])
        img{i}=imread(imglist,i);
    end
elseif isa(imglist,'cell') % a list of file names
    img=cell(L,1);
    for i=1:L
        %     disp(['Processing ',imglist{i},'...'])
        img{i}=imread(imglist{i}); % read the image
    end
elseif isa(imglist,'numeric') % a volume input
    L=size(imglist,3);
    img=cell(L,1);
    for i=1:L
        img{i}=squeeze(imglist(:,:,i,:)); % read out coronal sections
    end
end
C=size(img{1},3);
%% map to atlas
imgatlasmap=cell(size(imglist,1),C);
for i=1:L
    if ~isempty(seclist)
        % key step of orientating the annotation
        annomap=squeeze(annoimgs(:,40+seclist(i),:)); % 40 anterior padding
    else
        annomap=squeeze(annoimgs(:,i,:));
    end
    %     annomap=flip(annomap,1); % flip upside down
    for c=1:C
        imgatlasmap{i,c}=single(zeros(size(annomap)));
        ifempty=sum(sum(img{i}(:,:,c)));
        if ifempty>0
            if toresample==1
                %                 imgmask_up=repelem(img{i}(:,:,c),dsrate,dsrate);
                %                 imgmask_match=downsample_max(imgmask_up,conversion_factor,conversion_factor); % matched to annotation map resolution
                imgmask_match=imadj_resolution(img{i}(:,:,c),originres,annores);
            else
                imgmask_match=squeeze(img{i}(:,:,c));
            end
            imgmask_match=single(imgmask_match(1:H1,1:W1));
            imgatlasmap{i,c}=annomap.*imgmask_match;
        end
    end
    %     disp('Mapped.')
end
signalmap_anno=cell(1,C);
% 1. by color channel
for c=1:C
    signalmap_anno{c}=uint16(zeros(size(annoimgs)));
    % 2. record all voxel locations on annotation.img
    % (note: later on we can apply the distortion map to restore the true volume)
    if ~isempty(seclist)
        for i=1:L
            signalmap_anno{c}(:,40+seclist(i),:)=uint16(imgatlasmap{i,c});
            % map back to the annotation.img
        end
    else
        for i=1:L
            signalmap_anno{c}(:,i,:)=uint16(imgatlasmap{i,c});
            % map back to the annotation.img
        end
    end
end
%% save in volume
if nargin==7
    if ~isempty(outputfile) % save the volume
        % separate color channels and save in 3D
        [filepath,filename,~]=fileparts(outputfile);
        % 1. by color channel
        for c=1:C
            % save
            for w=1:W1
                if w==1
                    imwrite(signalmap_anno{c}(:,:,w),[filepath,'/',filename,'_',num2str(c),'.tif'],'writemode','overwrite','compression','none')
                else
                    imwrite(signalmap_anno{c}(:,:,w),[filepath,'/',filename,'_',num2str(c),'.tif'],'writemode','append','compression','none')
                end
            end
        end
    end
end