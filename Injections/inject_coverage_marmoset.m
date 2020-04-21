%%
annoimgfile='/Users/bingxinghuo/Dropbox (Mitra Lab)/Data and Analysis/Marmoset/MarmosetBrainAtlases/2015 RIKEN/Brian transformed atlas/annotation_80_flip.img';
annoimgs=analyze75read(annoimgfile);
%%
% AP=0 coronal plane (ear bar) is at annoimgs(326,:,:)
origin=[326,0,170];
%%
% uiopen('/Users/bingxinghuo/Dropbox (Mitra Lab)/Data and Analysis/Marmoset/Joint_Analysis/Navigator_injection (2).csv',1)
Navigatorinjection2 = sortrows(Navigatorinjection2,'VarName2','descend');
allinj=table2cell(Navigatorinjection2);
injbytracer{1}=allinj(1:46,:); % RED
injbytracer{2}=allinj(47:98,:); % GFP
injbytracer{3}=allinj(99:146,:); % FastBlue
injbytracer{4}=allinj(147:156,:); % DY
injinfoall=cell(4,1);
for d=1:length(injbytracer)
    injinfoall{d}=cell(size(injbytracer{d},1),1);
    for i=1:size(injbytracer{d},1)
        injcent=cell2mat(injbytracer{d}(i,3:5));
        if sum(injcent)~=0
            injinfoall{d}{i}.id=injbytracer{d}{i,1};
            injcent1(1)=round(326-injcent(1)*1000/80); % anterior is negative
            injcent1(3)=round(170-injcent(2)*1000/80); % right hemisphere
            zline=squeeze(annoimgs1(injcent1(1),:,injcent1(3)));
            zlineloc=find(zline);
            if ~isempty(zlineloc)
                zlinetop=zlineloc(1);
                injcent1(2)=round(zlinetop-injcent(3)*1000/80);
            else
                corsec=squeeze(annoimgs(injcent1(1),:,:));
                [dv,ml]=find(corsec);
                if injcent(2)>0 % right hemisphere
                    [injcent1(3),ind]=min(ml);
                    injcent1(2)=dv(ind);
                else
                    [injcent1(3),ind]=max(ml);
                    injcent1(2)=dv(ind);
                end
            end
            injinfoall{d}{i}.com=injcent1;
        end
    end
end
save('allinjinfo','Navigatorinjection2','injinfoall')
%% visualize
tracers={'ante';'retro'};
for t=1:2
    centvol=zeros(size(annoimgs));
    for d=(t-1)*2+1:t*2
        for i=1:length(injinfoall{d})
            if ~isempty(injinfoall{d}{i})
                centvol(injinfoall{d}{i}.com(1),injinfoall{d}{i}.com(2),injinfoall{d}{i}.com(3))=injinfoall{d}{i}.id;
            end
        end
    end
    se=strel('sphere',5);
    centvol=imdilate(centvol,se);
    imwrite(uint16(centvol(:,:,1)),['inj_',tracers{t},'_marmoset.tif'],'writemode','overwrite','compression','packbit')
    for i=2:size(centvol,3)
        imwrite(uint16(centvol(:,:,i)),['inj_',tracers{t},'_marmoset.tif'],'writemode','append','compression','packbit')
    end
end
%% horizontal view

for t=1:2
    horifile=['combined_injection_centers_',tracers{t},'_horizontal.eps'];
    figure, imagesc(squeeze(sum(annoimgs1,2))>0)
    hold on
    %     caxis([0 10000])
    colormap gray
    axis image; axis off
    legendi=[];
    k=0;
    for a=(t-1)*2+1:t*2
        for i=1:size(injinfoall{a},1)
            if ~isempty(injinfoall{a}{i})
                scatter(injinfoall{a}{i}.com(3),injinfoall{a}{i}.com(1),20)
                k=k+1;
                legendi=[legendi;injinfoall{a}{i}.id];
            end
        end
    end
    title(['Total of ',num2str(k),' injections.'])
    legend(num2str(legendi))
    saveas(gca,horifile,'epsc')
end
%% sagittal view
% sagittal
for t=1:2
    sagifile=['combined_injection_centers_',tracers{t},'_sagittal.eps'];
    %     atlas outline, sagittal
    figure, imagesc(squeeze(sum(annoimgs1,3))>0)
    hold on
    caxis auto
    colormap gray
    axis image; axis off
    legendi=[];
    k=0;
    for a=(t-1)*2+1:t*2
        for i=1:size(injinfoall{a},1)
            if ~isempty(injinfoall{a}{i})
                scatter(injinfoall{a}{i}.com(2),injinfoall{a}{i}.com(1),20)
                k=k+1;
                legendi=[legendi;injinfoall{a}{i}.id];
            end
        end
    end
    legend(num2str(legendi))
    title(['Total of ',num2str(k),' injections.'])
    %     saveas(gca,sagifile,'epsc')
end