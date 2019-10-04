detecttype='process';
for i=6
    animalid=motorbraininfo(i).animalid;
    bitinfo=motorbraininfo(i).bitinfo;
    injcolor=motorbraininfo(i).injectcolor;
    outputdir=[targetdir,upper(animalid)];
    flips=motorbraininfo(i).flips;
    %% load annotation
    annoimgfile=[outputdir,'/',upper(animalid),'_annotation.img'];
    annostack=load_nii(annoimgfile);
    annoimgs=annostack.img;
    annoimgs(annoimgs>=10000)=annoimgs(annoimgs>=10000)-10000; % adjust LR hemisphere difference
    if ~isempty(flips)
        for f=1:length(flips)
            annoimgs=flip(annoimgs,flips(f));
        end
    end
    [H1,N1,W1]=size(annoimgs);
    mapinjvol=zeros(H1,N1,W1);
    %% load injection
    for c=1:3
        mapinjvolfile=[outputdir,'/',animalid,'_map',detecttype,'_',num2str(c),'.tiff'];
        if exist(mapinjvolfile,'file')
            mapinjidfile=[outputdir,'/',animalid,'_map',detecttype,'ID_',num2str(c),'.tiff'];
            for w=1:W1
                mapinjvol(:,:,w)=imread(mapinjvolfile,w);
            end
            mapinjid=uint16((mapinjvol>100).*annoimgs);
            imwrite(mapinjid(:,:,1),mapinjidfile,'writemode','overwrite','compression','none')
            for w=2:W1
                imwrite(mapinjid(:,:,w),mapinjidfile,'writemode','append','compression','none')
            end
        end
    end
end