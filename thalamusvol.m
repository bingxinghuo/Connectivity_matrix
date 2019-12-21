%% 1. define ROI IDs
% marmoset
% regid=M1thal(:,3);
% regid=M1ant.common(regind,3);
marmosetdenomind=253; % thalamus
marmothalchilds=childreninfo(marmosetlist,marmosetdenomind,0,2);
thal.tot.marmoset=brainregionvol(marmosetlist,marmosetdenomind,0);
thal.marmoset=marmothalchilds(cell2mat(marmothalchilds(:,1))==5,4);
thalchilds1=marmothalchilds(cell2mat(marmothalchilds(:,1))<5,:);
for j=1:size(thalchilds1,1)
    if isempty(thalchilds1{j,8})
        thal.marmoset=[thal.marmoset;thalchilds1(j,4)];
    end
end
for i=1:size(regid,1)
    thal.marmoset{i,2}=brainregionvol(marmosetlist,thal.marmoset{i,1},0); % calculate volume
    thal.marmoset{i,3}=regionsinLUT(thal.marmoset{i,1},LUT.marmoset,marmosetlist); % find index in LUT
end
% mouse
mousedenomind=549; % thalamus
thal.tot.mouse=brainregionvol(mouselist,mousedenomind,0);
mousethalchilds=childreninfo(mouselist,mousedenomind,0);
thal.mouse=mousethalchilds(cell2mat(mousethalchilds(:,1))==7,4);
thalchilds1=mousethalchilds(cell2mat(mousethalchilds(:,1))<7,:);
for j=1:size(thalchilds1,1)
    if isempty(thalchilds1{j,8})
        thal.mouse=[thal.mouse;thalchilds1(j,4)];
    end
end
for i=1:length(thal.mouse)
    thal.mouse{i,2}=brainregionvol(mouselist,thal.mouse{i,1},0); % calculate volume
    thal.mouse{i,3}=regionsinLUT(thal.mouse{i,1},LUT.mouse,mouselist);
end
%% matched volumes
LUTthal.ind=unique(cell2mat(thal.marmoset(:,3)),'stable');
for i=1:length(LUTthal.ind)
    marmosetid=LUT.marmoset{LUTthal.ind(i),1};
    LUTthal.marmosetid{i,1}=marmosetid;
    vol=0;
    for k=1:length(marmosetid)
        vol=vol+brainregionvol(marmosetlist,marmosetid(k),0);
    end
    LUTthal.marmosetvol(i,1)=vol;
    mouseid=LUT.mouse{LUTthal.ind(i),1};
    LUTthal.mouseid{i,1}=mouseid;
    vol=0;
    for k=1:length(mouseid)
        vol=vol+brainregionvol(mouselist,mouseid(k),0);
    end
    LUTthal.mousevol(i,1)=vol;
end
%%
LUTthal.LUTind=unique([cell2mat(thal.mouse(:,3));cell2mat(thal.marmoset(:,3))]);
for i=1:length(LUTthal.LUTind)
    mouseind=find(cell2mat(thal.mouse(:,3))==LUTthal.LUTind(i));
    if ~isempty(mouseind)
        if length(mouseind)>1
            LUTthal.mouse{i,1}=cell2mat(thal.mouse(mouseind,1));
            LUTthal.mouse{i,2}=cell2mat(thal.mouse(mouseind,2));
            LUTthal.mouse{i,3}=cell2mat(thal.mouse(mouseind,3));
        else
            LUTthal.mouse(i,:)=thal.mouse(mouseind,:);
        end
    end
end
for i=1:length(LUTthal.LUTind)
    marmosetind=find(cell2mat(thal.marmoset(:,3))==LUTthal.LUTind(i));
    if ~isempty(marmosetind)
        if length(marmosetind)>1
            LUTthal.marmoset{i,1}=cell2mat(thal.marmoset(marmosetind,1));
            LUTthal.marmoset{i,2}=cell2mat(thal.marmoset(marmosetind,2));
            LUTthal.marmoset{i,3}=cell2mat(thal.marmoset(marmosetind,3));
        else
            LUTthal.marmoset(i,:)=thal.marmoset(marmosetind,:);
        end
    end
end
%%
mouseidlist=cell2mat(mouselist(:,4));
marmosetidlist=cell2mat(marmosetlist(:,4));
for i=1:length(LUTthal.LUTind)
    mouseids=LUT.mouse{LUTthal.LUTind(i),1};
    mouseind=zeros(length(mouseids),1);
    for j=1:length(mouseids)
        mouseind(j)=find(mouseidlist==mouseids(j));
    end
    LUTthal.LUTabb.mouse{i,1}=strjoin(mouselist(mouseind,2),',');
    marmosetids=LUT.marmoset{LUTthal.LUTind(i),1};
    marmosetind=zeros(length(marmosetids),1);
    for j=1:length(marmosetids)
        marmosetind(j)=find(marmosetidlist==marmosetids(j));
    end
    LUTthal.LUTabb.marmoset{i,1}=strjoin(marmosetlist(marmosetind,2),',');
end
%%
% regid=M1thal(:,1);
% regid=M1ant.common(regind,1);
for i=1:length(regid)
    childsid=[];
    for l=1:length(regid{i})
        childs=childreninfo(mouselist,regid{i}(l),0);
        childsid=[childsid;cell2mat(childs(:,4))];
        regleafid{i,1}=childsid;
    end
end
%%
for i=1:length(regid)
    regvol=logical(zeros(size(mouseanno.data)));
    for l=1:length(regleafid{i,1})
        regvol=regvol+(mouseanno.data==regleafid{i,1}(l));
    end
    regleafid{i,2}=sum(sum(sum(regvol>0)));
end
%% fraction
mousedenomind=549; % thalamus
% mousedenomind=8; % whole brain
if mousedenomind==8
    load('~/Dropbox (Marmoset)/BingxingHuo/Atlas Hierarchy/Mouse/P56_Mouse_annotation/mouseregions_100um.mat', 'gray')
    volallnum=gray.vol*2^3;
else
    childs=childreninfo(mouselist,mousedenomind,0);
    childs=cell2mat(childs(:,4));
    regvolall=logical(zeros(size(mouseanno.data)));
    for i=1:length(childs)
        regvolall=regvolall+(mouseanno.data==childs(i));
    end
    volallnum=sum(sum(sum(regvolall>0)));
end
for i=1:length(regid)
    regleafid{i,3}=regleafid{i,2}/volallnum;
end
% M1regvol.mouse=regleafid;
%% marmoset
clear regleafid
marmosetatlas=load_nii('~/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/Marmoset Atlases/2015 RIKEN/Woodward_2018/bma-1-region_seg.nii');
atlas3d=marmosetatlas.img;
atlas3d(atlas3d>10000)=atlas3d(atlas3d>10000)-10000;
%%
% regid=M1thal(:,3);
% regid=M1ant.common(regind,3);
marmosetdenomind=253; % thalamus
childs=childreninfo(marmosetlist,marmosetdenomind,0,2);
regid=childs(cell2mat(childs(:,1))==5,4);
regname=childs(cell2mat(childs(:,1))==5,[2,4]);
for i=1:length(regid)
    childsid=[];
    for l=1:length(regid{i})
        childs=childreninfo(marmosetlist,regid{i}(l),0);
        childsid=[childsid;cell2mat(childs(:,4))];
        regleafid{i,1}=childsid;
    end
end
for i=1:length(regid)
    regvol=logical(zeros(size(atlas3d)));
    for l=1:length(regleafid{i,1})
        regvol=regvol+(atlas3d==regleafid{i,1}(l));
    end
    regleafid{i,2}=sum(sum(sum(regvol>0)));
end
regleafid=[regname,regid,regleafid];
%% thalamus
% marmosetdenomind=253; % thalamus
% marmosetdenomind=cell2mat(regionlabel(toplevelind,1));
% marmosetdenomind=1;
if marmosetdenomind==1
    load('~/Dropbox (Marmoset)/BingxingHuo/Atlas Hierarchy/Marmoset/marmosetregions.mat', 'greymatter');
    volallnum=greymatter.sumpix;
else
    childs=childreninfo(marmosetlist,marmosetdenomind,0);
    childs=cell2mat(childs(:,4));
    regvolall=logical(zeros(size(atlas3d)));
    for i=1:length(childs)
        regvolall=regvolall+(atlas3d==childs(i));
    end
    volallnum=sum(sum(sum(regvolall>0)));
end
for i=1:length(regid)
    regleafid{i,3}=regleafid{i,2}/volallnum;
end
M1regvol.marmoset=regleafid;
%%
figure, bar([cell2mat(M1regvol.mouse(:,3)),cell2mat(M1regvol.marmoset(:,3))])
xlim([0,size(M1regvol.mouse,1)+1])
ylim([0 .15])
saveas(gcf,[savedir,'thalnucleivol_perc.fig'])
saveas(gcf,[savedir,'thalnucleivol_perc.eps'],'epsc')
close