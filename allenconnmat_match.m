load('CCFregionlist.mat', 'AllenConnMatregions')
%%
commonmouseLUTind=nonzeros(unique(M1ant.mouse(:,3)));
LUT1=cell(size(LUT.mouse));
LUT1(commonmouseLUTind,:)=LUT.mouse(commonmouseLUTind,:);
%% find region indices in the LUT
Allenmatch=zeros(size(AllenConnMatregions,1),1);
for i=1:size(AllenConnMatregions,1)
    AllenConnMatregions(i,3)=mouselist(AllenConnMatregions{i,2},4);
    Allenmatch(i)=regionsinLUT(AllenConnMatregions{i,3},LUT1,mouselist);
end
%% find region indices in the LUT
Allenmatch=num2cell(Allenmatch);
for i=1:length(Allenmatch)   
    if Allenmatch{i}==0
        Allenmatch{i}=[];
            childs=childreninfo(mouselist,AllenConnMatregions{i,3},0);
            childsid=cell2mat(childs(2:end,4));
            for k=1:length(childsid)
                Allenmatch{i}=[Allenmatch{i};regionsinLUT(childsid(k),LUT1,mouselist)];
            end
    end
end
%% find region indices in the LUT
for i=1:length(Allenmatch)   
    if sum(Allenmatch{i})==0
        k=0;
        Allenmatch{i}=0;
        parents=lineageinfo(mouselist,AllenConnMatregions{i,3},0);
            parentsid=flip(cell2mat(parents(:,4)));
        while sum(Allenmatch{i})==0
            k=k+1;
            
            Allenmatch{i}=regionsinLUT(parentsid(k),LUT1,mouselist);
        end
    end
end
%% match with top level regions
for i=1:length(Allenmatch)
    if length(Allenmatch{i,1})>1
        regionid=unique(nonzeros(Allenmatch{i,1}));
    else
        regionid=Allenmatch{i,1};
    end
    regionid=LUT.marmoset{regionid,1};
    L=[];
    for j=1:length(regionid)
        for t=1:size(regionlabel,1)
            if sum(regionlabel{t,3}==regionid(j))>0
                L=[L;t];
            end
        end
    end
    Allenmatch{i,2}=unique(L);
end
%%
% Allenmatch_supp={};
k=1;
for i=1:length(Allenmatch)
    if isempty(Allenmatch{i,2})
        Allenmatch{i,2}=0;
%         Allenmatch_supp{k,1}=Allenmatch{i,1};
%         k=k+1;
    end
end
% Allenmatch{44,2}=1; % no match of dorsal peduncular area in marmoaset atlas. Manual input. 
% Allenmatch{46,2}=1; % no match of ectorhinal area in marmoaset atlas. Manual input. 
% Allenmatch{67,2}=6; % no match of fundus of striatum in marmoaset atlas. Manual input. 
% Allenmatch{83,2}=11; % no match of Magnocellular reticular nucleus in marmoset atlas. Manual input.
% Allenmatch{104,2}=12; % no match of nucleus incertus in marmoset atlas. Manual input.
% Allenmatch{160,2}=7; % no match of Subparaventricular zone in marmoset atlas. Manual input.
% Allenmatch{187,2}=7; % no match of supramammillary nucleus in marmoset atlas. Manual input.
% Allenmatch{207,2}=8; % no match of submedial nucleus of thalamus in marmoset atlas. Manual input.
%%
load('~/Dropbox (Marmoset)/BingxingHuo/Mouse/MotorCortex/Allen/MOConnMat.mat', 'eff_ipsi','eff_contra')
eff_ipsi=eff_ipsi';
eff_contra=eff_contra';
eff_ipsi_perc=eff_ipsi./(ones(size(eff_ipsi,1),1)*sum([eff_ipsi;eff_contra]));
eff_contra_perc=eff_contra./(ones(size(eff_ipsi,1),1)*sum([eff_ipsi;eff_contra]));
% M1allenmat.ipsi=eff_ipsi(:,1)/(sum(eff_ipsi(:,1)+eff_contra   (:,1)));
% M1allenmat.contra=eff_contra(:,1)/(sum(eff_ipsi(:,1)+eff_contra(:,1)));
% M2allenmat.ipsi=eff_ipsi(:,2)/(sum(eff_ipsi(:,2)+eff_contra(:,2)));
% M2allenmat.contra=eff_contra(:,2)/(sum(eff_ipsi(:,2)+eff_contra(:,2)));
M1allenmat.ipsi=eff_ipsi_perc(:,1);
M1allenmat.contra=eff_contra_perc(:,1);
M2allenmat.ipsi=eff_ipsi_perc(:,2);
M2allenmat.contra=eff_contra_perc(:,2);
for i=1:size(regionlabel,1)
    topregions=find(cell2mat(Allenmatch(:,2))==i);
    M1allenmat.top(i,:)=sum((M1allenmat.ipsi(topregions))+M1allenmat.contra(topregions));
    M2allenmat.top(i,:)=sum((M2allenmat.ipsi(topregions))+M2allenmat.contra(topregions));
end
%%
figure, bar([M1commonmat.top,M1allenmat.top])
legend('mouse MOp','marmoset A4ab','AIBS mouse MOp')
xlim([0,size(regionlabel,1)+1])
ylim([0 .5])
saveas(gcf,[savedir,'M1allenconnbar_highlevel.fig'])
saveas(gcf,[savedir,'M1allenconnbar_highlevel.eps'],'epsc')
close
figure, bar([M2commonmat.top,M2allenmat.top])
legend('mouse MOs','marmoset A6','AIBS mouse MOs')
xlim([0,size(regionlabel,1)+1])
ylim([0 .5])
saveas(gcf,[savedir,'M2allenconnbar_highlevel.fig'])
saveas(gcf,[savedir,'M2allenconnbar_highlevel.eps'],'epsc')
close