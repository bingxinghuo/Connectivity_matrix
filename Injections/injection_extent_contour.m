animalids={'m920'};
% animalids={'m820';'m822'};
% animalids={'m919';'m1144';'m1146';'m1147';'m1148'};
targetdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Paul Martin/';
for a=1:length(animalids)
    animalid=animalids{a};
    % set directory
    animalid=lower(animalid); % in case the input is upper case
    savedir=[targetdir,upper(animalid),'/injection/'];
    cd(savedir)
    annostack=load_nii([targetdir,upper(animalid),'/',animalid,'_annotation.img']);
    annoimgs=annostack.img;
    annoimgs(annoimgs>=10000)=annoimgs(annoimgs>=10000)-10000; % adjust LR hemisphere difference
    conversion_factor=round(80/(.46*3)); %920
%     conversion_factor=round(80/(.46*2));
    %% coronal
    coranno=imread([upper(animalid),'_inj_anno_cor.png']);
    [H,W,c]=size(coranno);
    % brain outline
    annocor=sum(annoimgs,2);
%     annocor1=annocor; % m820, m822
    annocor1=flipdim(annocor,1);
    bwcor=annocor1>0;
    bwcor=squeeze(bwcor);
    bwcor1=repelem(bwcor,conversion_factor,conversion_factor);
    bwcor2=downsample_max(bwcor1,64,64);
    bwcor2=bwcor2(1:H,1:W);
    bwcor2=imfill(bwcor2,'holes');
    bwcoredge=edge(bwcor2);
    bwcorcontour=cat(3,bwcoredge,bwcoredge,bwcoredge);
    coranno=coranno-uint8(bwcorcontour*255);
    traceredgecor=cell(3,1);
    figure(100),clf, imagesc(coranno)
    for c=1:3
        if sum(sum(coranno(:,:,c)))>10
        tracercor=coranno(:,:,c);
        cc=bwconncomp(tracercor);
        %     numPixels = cellfun(@numel,cc.PixelIdxList);
        %     [biggest,idx] = max(numPixels);
        L=labelmatrix(cc);
        figure(100),title(num2str(c))
        [x,y]=ginput(1);
        idx=L(round(y),round(x));
        traceredge=bwboundaries(L==idx);
        Nedgecount=length(traceredge);
        if Nedgecount>1
            edgecount=zeros(Nedgecount,1);
            for i=1:Nedgecount
                edgecount(i)=size(traceredge{i},1);
            end
            [~,edgei]=max(edgecount);
            traceredge=traceredge{edgei};
        else
            traceredge=traceredge{1};
        end
        traceredgecor{c}=polyshape(traceredge);
        end
    end
    figure, hold on
    for i=1:3
        if ~isempty(traceredgecor{i})
        plot(traceredgecor{i})
        end
    end
    braincoredge=bwboundaries(bwcor2);
    braincor=polyshape(cell2mat(braincoredge));
    plot(braincor)
    axis image
    axis off
    alpha 1
    print([savedir,upper(animalid),'_cor_injext.eps'],'-depsc')
    close
    %% sagittal
    saganno=imread([upper(animalid),'_inj_anno_sag.png']);
    annosag=sum(annoimgs,3);
    annosag1=flipdim(annosag,1);
    annosag1=flipdim(annosag1,2);
%     annosag1=annosag; % m820, m822
    bwsag=annosag1>0;
    bwsag1=repelem(bwsag,conversion_factor,1);
    bwsag2=downsample_max(bwsag1,64,1);
    bwsag2=bwsag2(1:H,:);
    bwsag2=imfill(bwsag2,'holes');
    bwsagedge=edge(bwsag2);
    bwsagcontour=cat(3,bwsagedge,bwsagedge,bwsagedge);
    saganno=saganno-uint8(bwsagcontour*255);
    traceredgesag=cell(3,1);
    figure(100),clf, imagesc(saganno)
    for c=1:3
        if sum(sum(saganno(:,:,c)))>10
        tracersag=saganno(:,:,c);
        cc=bwconncomp(tracersag);
        %     numPixels = cellfun(@numel,cc.PixelIdxList);
        %     [biggest,idx] = max(numPixels);
        L=labelmatrix(cc);
        figure(100),title(num2str(c))
        [x,y]=ginput(1);
        idx=L(round(y),round(x));
        traceredge=bwboundaries(L==idx);
        Nedgecount=length(traceredge);
        if Nedgecount>1
            edgecount=zeros(Nedgecount,1);
            for i=1:Nedgecount
                edgecount(i)=size(traceredge{i},1);
            end
            [~,edgei]=max(edgecount);
            traceredge=traceredge{edgei};
        else
            traceredge=traceredge{1};
        end
        traceredgesag{c}=polyshape(traceredge);
        end
    end
    figure, hold on
    for i=1:3
        if ~isempty(traceredgesag{i})
        plot(traceredgesag{i})
        end
    end
    brainsagedge=bwboundaries(bwsag2);
    brainsag=polyshape(cell2mat(brainsagedge));
    plot(brainsag)
    axis image
    axis off
    alpha 1
    print([savedir,upper(animalid),'_sag_injext.eps'],'-depsc')
    close
    %% transverse
    transanno=imread([upper(animalid),'_inj_anno_trans.png']);
    annotrans=sum(annoimgs,1);
    annotrans1=squeeze(annotrans);
    annotrans2=imrotate(annotrans1,-90);
%     annotrans2=imrotate(annotrans1,90); % m820, m822
    bwtrans=annotrans2>0;
    bwtrans1=repelem(bwtrans,conversion_factor,1);
    bwtrans2=downsample_max(bwtrans1,64,1);
    bwtrans2=bwtrans2(1:W,:);
    bwtrans2=imfill(bwtrans2,'holes');
    bwtransedge=edge(bwtrans2);
    bwtranscontour=cat(3,bwtransedge,bwtransedge,bwtransedge);
    transanno=transanno-uint8(bwtranscontour*255);
    traceredgetrans=cell(3,1);
    figure(100),clf, imagesc(transanno)
    for c=1:3
        if sum(sum(transanno(:,:,c)))>10
        tracertrans=transanno(:,:,c);
        cc=bwconncomp(tracertrans);
        %     numPixels = cellfun(@numel,cc.PixelIdxList);
        %     [biggest,idx] = max(numPixels);
        L=labelmatrix(cc);
        figure(100),title(num2str(c))
        [x,y]=ginput(1);
        idx=L(round(y),round(x));
        traceredge=bwboundaries(L==idx);
        Nedgecount=length(traceredge);
        if Nedgecount>1
            edgecount=zeros(Nedgecount,1);
            for i=1:Nedgecount
                edgecount(i)=size(traceredge{i},1);
            end
            [~,edgei]=max(edgecount);
            traceredge=traceredge{edgei};
        else
            traceredge=traceredge{1};
        end
        traceredgetrans{c}=polyshape(traceredge);
        end
    end
    figure, hold on
    for i=1:3
        if ~isempty(traceredgetrans{i})
        plot(traceredgetrans{i})
        end
    end
    braintransedge=bwboundaries(bwtrans2);
    braintrans=polyshape(cell2mat(braintransedge));
    plot(braintrans)
    axis image
    axis off
    alpha 1
    print([savedir,upper(animalid),'_trans_injext.eps'],'-depsc')
    close
end