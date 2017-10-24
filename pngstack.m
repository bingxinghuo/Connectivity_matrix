% in this matlab script, the variable "slicenumbers" will contain the
% actual slice number for each image in order. then you can populate a
% matrix like myvolume(:,slicenumbers(i),:) = myslice


directoryname = '/Users/bingxinghuo/Dropbox (Marmoset)/Riken Data/Reconstrcution/ForBrianLee/NewBrain/M919_N';
directory = dir(directoryname);
adr = {};
k = 1;
for i = 1:size(directory,1)
    if ~isempty(regexp(directory(i).name, '.png', 'once'))
        adr{k} = directory(i).name;
        k = k+1;
    end
end

slicenumbers = zeros(1,size(adr,2));
% for i = 1:size(adr,2)
%     slicenumbers(i) = str2num(adr{i}(end-7:end-4));
% end

% adam says the last number in the file name is meaningless. He says the
% actual way to see if any slices are missing are to look at the number
% after "N". If 1 or 2 is missing then a slice is missing. Except for
% 149-225, those have only one slice per slide.
for i = 1:size(adr,2)
    uind1 = regexp(adr{i},'N');
    uind2 = regexp(adr{i},'--');
    slidenum = str2num(adr{i}(uind1+1:uind2-1));
    % for m820 only
    slidepos = str2num(adr{i}(uind2+3))-1;
    %slidepos = str2num(adr{i}(uind2+3));
    if i == 1
        lastslidenum = slidenum;
        lastslidepos = slidepos;
        slicenumbers(i) = 1;
        continue
    end
    if lastslidenum == slidenum
        slicenumbers(i) = slicenumbers(i-1) + 1;
    else
        % m983
        %if slidenum < 149 || slidenum > 225
        % m919new
        %if slidenum < 77 || slidenum > 120
        % m820new
        if slidenum < 51 || slidenum > 200
            slicenumbers(i) = slicenumbers(i-1) + (slidenum - lastslidenum-1)*2 + (slidepos-lastslidepos+2);
        else
            slicenumbers(i) = slicenumbers(i-1) + (slidenum - lastslidenum-1)*1 + 1;
        end
    end
    lastslidenum = slidenum;
    lastslidepos = slidepos;
end
%%
dims(2)=max(slidenum);
nisslimg=imread(adr{1});
[dims(1),dims(3),~]=size(nisslimg);
slidestack=zeros(dims);
for i = 1:k-1
    nisslimg=imread(adr{i});
    nisslimg1=mean(nisslimg,3);
    imgmask=brainmaskfun_nissl(nisslimg);
    nisslimg2=nisslimg1.*imgmask;
    slidestack(:,i,:)=nisslimg2';
end

for i=1:dims(1)
slidestack1(:,:,i)=slidestack(:,:,dims(1)-i+1);
end