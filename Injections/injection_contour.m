injpolygon=cell(length(filelist),4);
injpolygon(:,1)=filelist;
injrange=PFCmarmosetinfo(1).injrange;
f1=min(injrange(:,1));
f2=max(injrange(:,2));
for f=f1:f2
    injmask=imread(filelist{f});
    for c=1:3
        if f>=injrange(c,1) && f<=injrange(c,2)
            if sum(sum(injmask(:,:,c)))>0
                A=bwboundaries(injmask(:,:,c));
                boundsize=cellfun(@length,A);
                A=A(boundsize==max(boundsize));
                injpolygon(f,c+1)=A;
            end
        end
    end
end