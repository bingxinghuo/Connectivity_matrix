annoimgfile='/Users/bingxinghuo/Dropbox (Mitra Lab)/Data and Analysis/Marmoset/MarmosetBrainAtlases/2015 RIKEN/Brian transformed atlas/annotation_80_flip.img';
annoimgs=analyze75read(annoimgfile);
%%
annoimgs1=annoimgs;
annoimgs1(annoimgs1>=10000)=annoimgs1(annoimgs1>=10000)-10000;
%%
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
sagiproj=zeros(Y,Z);
for z=1:Z
    for y=1:Y
        x1=find(annoimgs1(:,y,z));
        if ~isempty(x1)
            sagiproj(y,z)=annoimgs1(x1(1),y,z);
        end
    end
end
%%
surfregionid=sort(nonzeros(unique(horiproj)),'ascend');
N=length(surfregionid);
regionoutline=cell(N,1);
figure, hold on
%%
for i=1:N
    regionpoly=regioncontour(horiproj==surfregionid(i));
    for j=1:size(regionpoly)
       plot(regionpoly{j})
    end
end
alpha 1
%%
% AP=0 coronal plane (ear bar) is at annoimgs(326,:,:)
origin=[326,0,170];