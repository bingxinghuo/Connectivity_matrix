annoimgfile='/Users/bingxinghuo/Dropbox (Mitra Lab)/Data and Analysis/Marmoset/MarmosetBrainAtlases/2015 RIKEN/Brian transformed atlas/annotation_80_flip.img';
annoimgs=analyze75read(annoimgfile);
%%
annoimgs1=annoimgs;
annoimgs1(annoimgs1>=10000)=annoimgs1(annoimgs1>=10000)-10000;
%% horizontal
[X,Y,Z]=size(annoimgs1);
horiproj=zeros(X,Z);
for z=1:Z
    for x=1:X
        y1=find(annoimgs1(x,:,z));
        if ~isempty(y1)
            horiproj(x,z)=annoimgs1(x,y1(1),z);
        end
    end
end
%% 
surfregionid=sort(nonzeros(unique(horiproj)),'ascend');
N=length(surfregionid);
figure, hold on
for i=1:N
    regionpoly=regioncontour(horiproj==surfregionid(i));
    for j=1:size(regionpoly)
       plot(regionpoly{j})
    end
end
alpha 1
axis image
saveas(gca,'annotation_horizontal.eps','epsc')
%% coronal
coronalproj=zeros(Y,Z);
for z=1:Z
    for y=1:Y
        x1=find(annoimgs1(:,y,z));
        if ~isempty(x1)
            coronalproj(y,z)=annoimgs1(x1(1),y,z);
        end
    end
end
%%
surfregionid=sort(nonzeros(unique(coronalproj)),'ascend');
N=length(surfregionid);
figure, hold on
for i=1:N
    regionpoly=regioncontour(coronalproj==surfregionid(i));
    for j=1:size(regionpoly)
       plot(regionpoly{j})
    end
end
alpha 1
axis image
saveas(gca,'annotation_coronal.eps','epsc')
%% sagittal
sagiproj=zeros(X,Y);
for x=1:X
    for y=1:Y
        z1=find(annoimgs1(x,y,:));
        if ~isempty(z1)
            sagiproj(x,y)=annoimgs1(x,y,z1(1));
        end
    end
end
%%
surfregionid=sort(nonzeros(unique(sagiproj)),'ascend');
N=length(surfregionid);
figure, hold on
for i=1:N
    regionpoly=regioncontour(sagiproj==surfregionid(i));
    for j=1:size(regionpoly)
       plot(regionpoly{j})
    end
end
alpha 1
axis image
saveas(gca,'annotation_sagittal.eps','epsc')