clear all
close all
%%
annoimgfile='/Users/bingxinghuo/Dropbox (Mitra Lab)/Data and Analysis/Marmoset/MarmosetBrainAtlases/2015 RIKEN/Brian transformed atlas/annotation_80_flip.img';
annoimgs=analyze75read(annoimgfile);
%%
inputdir='~/Dropbox (Mitra Lab)/Data and Analysis/Marmoset/Connectivity';
outputdir='~/Dropbox (Mitra Lab)/Data and Analysis/Marmoset/Joint_Analysis/Injection/';
brainlistfile=[inputdir,'/annotatedID.txt'];
% Read brain list
fid=fopen(brainlistfile);
brainIDlist=textscan(fid,'%q');
fclose(fid);
brainIDlist=brainIDlist{1};
signalfile=[inputdir,'/motorinjcolor.txt'];
% Read brain list
fid=fopen(signalfile);
signallist=textscan(fid,'%q');
fclose(fid);
signallist=signallist{1};
for i=1:length(signallist)
    signallist{i}=str2double(regexp(signallist{i},'\d','match'));
end
%%
clear injinfo
for d=1:length(brainIDlist)
    brainID=brainIDlist{d};
    injinfo(d).id=brainID;
    injinfo(d).injmaskatlas=uint16(zeros([size(annoimgs),3]));
    for s=1:length(signallist{d})
        injvolfile=dir([inputdir,'/',brainID,'/Cell_Detection/',brainID,'_mapinject_',num2str(signallist{d}(s)),'*clean*.img']);
        injvolfile=fullfile(injvolfile.folder,injvolfile.name);
        injimg=analyze75read(injvolfile);
        [injmask,injhullinfo]=injsoma2mask(injimg);
        injinfo(d).injmaskatlas(:,:,:,signallist{d}(s))=injmask;
        injinfo(d).injhullinfo{s}=injhullinfo;        
    end
end
savefile=[outputdir,'injinfo'];
if ~exist(savefile,'file')
    save(savefile,'injinfo','-v7.3')
end
%%
[injinfoall,injcovs,injcents]=injection_coverage_vis(injinfo,brainIDlist,signallist,1);
save(savefile,'injinfoall','injcovs','injcents','-append')
%% save downsampled masks
tracers={'antero','retro'};
for a=1:2
    centfile=[outputdir,'combined_injection_centers_',tracers{a},'.tif'];
    imwrite(uint16(injcents{a}(:,:,1)),centfile,'writemode','overwrite','compression','packbit')
    for j=2:size(injcents{a},3)
        imwrite(uint16(injcents{a}(:,:,j)),centfile,'writemode','append','compression','packbit')
    end
    %
    covfile=[outputdir,'combined_injection_coverage_',tracers{a},'.tif'];
    imwrite(uint16(injcovs{a}(:,:,1)),covfile,'writemode','overwrite','compression','packbit')
    for j=2:size(injcovs{a},3)
        imwrite(uint16(injcovs{a}(:,:,j)),covfile,'writemode','append','compression','packbit')
    end
end
%% save orthogonal projections
close all
sizenorm=cell2mat(injinfoall{1}(:,4));
sizenorm=((sizenorm*3/4/pi).^(1/3))*10; % marker size for illustration
annoimgs1=annoimgs;
annoimgs1(annoimgs1>=10000)=annoimgs1(annoimgs1>=10000)-10000;
for a=1:2
    % horizontal
    horifile=[outputdir,'combined_injection_centers_',tracers{a},'_horizontal.eps'];
    % atlas outline
    figure, imagesc(squeeze(sum(annoimgs1,2))>0)
    hold on
%     caxis([0 10000])
    colormap gray
    axis image; axis off
    % plot injection centers with representative size
    for i=1:size(injinfoall{a},1)
        scatter(injinfoall{a}{i,3}(3),injinfoall{a}{i,3}(1),sizenorm(i))
    end
    legend(injinfoall{a}(:,1))
    saveas(gca,horifile,'epsc')
    % sagittal
    sagifile=[outputdir,'combined_injection_centers_',tracers{a},'_sagittal.eps'];
%     atlas outline, sagittal
    figure, imagesc(squeeze(sum(annoimgs1,3))>0)
    hold on
    caxis auto
    colormap gray
    axis image; axis off
    % plot injection centers with representative size
    for i=1:size(injinfoall{a},1)
        scatter(injinfoall{a}{i,3}(2),injinfoall{a}{i,3}(1),sizenorm(i))
    end
    legend(injinfoall{a}(:,1))
    saveas(gca,sagifile,'epsc')
end
%% injection extent
colors={'R','G','B'};
for d=1:length(brainIDlist)
    brainID=brainIDlist{d};
    for s=1:length(signallist{d})
        signal=signallist{d}(s);
        %horizontal
        horifile=[inputdir,'/',brainID,'/Cell_Detection/',brainID,'_',colors{signal},'inj_atlas_horizontal.eps'];
        thickness=length(nonzeros(sum(sum(injinfo(d).injmaskatlas(:,:,:,signal),1),3)));
        horiproj=squeeze(sum(injinfo(d).injmaskatlas(:,:,:,signal),2))/thickness;
        figure, imagesc(horiproj,[0 1])
        hold on, scatter(injinfo(d).injhullinfo{s}.com(3),injinfo(d).injhullinfo{s}.com(1))
        axis image; axis off
        colormap gray
        saveas(gca,horifile)
        close;
        % sagittal
        sagifile=[inputdir,'/',brainID,'/Cell_Detection/',brainID,'_',colors{signal},'inj_atlas_sagittal.eps'];
        thickness=length(nonzeros(sum(sum(injinfo(d).injmaskatlas(:,:,:,signal),1),2)));        
        sagiproj=squeeze(sum(injinfo(d).injmaskatlas(:,:,:,signal),3))/thickness;
        figure, imagesc(sagiproj,[0 1])
        hold on, scatter(injinfo(d).injhullinfo{s}.com(2),injinfo(d).injhullinfo{s}.com(1))
        axis image; axis off
        colormap gray
        saveas(gca,sagifile)
        close;
    end
end