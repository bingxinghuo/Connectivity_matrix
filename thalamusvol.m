%% mouse
clear regleafid
% thalid=M1thal(:,1);
regid=M1ant.common(regind,1);
for i=1:length(regid)
    childsid=[];
    for l=1:length(regid{i})
        childs=childreninfo(mouselist,regid{i}(l),0);
        childsid=[childsid;cell2mat(childs(:,4))];
        regleafid{i,1}=childsid;
    end
end
% mouseanno=nhdr_nrrd_read('annotation_50.nrrd',1);
%%
for i=1:length(regid)
    regvol=logical(zeros(size(mouseanno.data)));
    for l=1:length(regleafid{i,1})
        regvol=regvol+(mouseanno.data==regleafid{i,1}(l));
    end
    regleafid{i,2}=sum(sum(sum(regvol>0)));
end
%% fraction
% mouseind=549; % thalamus
mousedenomind=8; % whole brain
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
M1regvol.mouse=regleafid;
%% marmoset
clear regleafid
% marmosetatlas=load_nii('bma-1-region_seg.nii');
% atlas3d=marmosetatlas.img;
% atlas3d(atlas3d>10000)=atlas3d(atlas3d>10000)-10000;
%%
% regid=M1thal(:,3);
regid=M1ant.common(regind,3);
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
%% thalamus
% marmosetdenomind=253; % thalamus
% marmosetdenomind=cell2mat(regionlabel(toplevelind,1));
marmosetdenomind=1;
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