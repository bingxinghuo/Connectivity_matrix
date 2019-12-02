regionname='hpf';
toplevelind=[3];
regind=[];
for l=1:length(toplevelind)
regind=[regind;find(M1commonmat.marmoset(:,2)==toplevelind(l))]; % thalamus high level index 
end
%%
olfregionname.marmoset=commonregionname.marmoset(regind);
olfregionname.mouse=commonregionname.mouse(regind);
save([savedir,'keystructnames'],[regionname,'regionname'],'-append')
%%
figure, imagesc(M1commonmat.marmoset(regind,1))
caxis([0 .02])
colormap hot
title(['M1 projection to ',regionname,',marmoset'])
saveas(gcf,[marmosetMOdir,'/M1antero_key_perc_Paxtree_v3_',regionname,'.eps'],'epsc')
close
figure, imagesc(M2commonmat.marmoset(regind,1))
caxis([0 .02])
colormap hot
title(['preM projection to ',regionname,',marmoset'])
saveas(gcf,[marmosetMOdir,'/preMantero_key_perc_Paxtree_v3_',regionname,'.eps'],'epsc')
close
figure, imagesc(M1commonmat.mouse(regind,1))
caxis([0 .02])
colormap hot
title('MOp projection to thalamus,mouse')
saveas(gcf,[mouseMOdir,'MOpantero_key_perc_Paxtree_v3_',regionname,'.eps'],'epsc')
close
figure, imagesc(M2commonmat.mouse(regind,1))
caxis([0 .02])
colormap hot
title('MOs projection to thalamus,mouse')
saveas(gcf,[mouseMOdir,'MOsantero_key_perc_Paxtree_v3_',regionname,'.eps'],'epsc')
close
%% thalamus
figure, bar([M1commonmat.mouse(regind,1),M1commonmat.marmoset(regind,1)])

% M1thal=M1ant.common(thalind,:); 
%  uid=unique(cell2mat(M1thal(:,1)));
% % consolidate repeated regions in leaf 
% repid=zeros(length(uid),1);
% for u=1:length(uid)
%     repcheck=cell2mat(M1thal(:,1))==uid(u);
%     occurrance=sum(repcheck);
%     if occurrance>1
%         repid(u)=uid(u);
%     end
% end
% repid=nonzeros(repid);
% figure, bar(cell2mat(M1thal(:,[2,4])))
legend('mouse MOp','marmoset A4ab')
% xlim([0,size(M1thal,1)+1])
ylim([0 .03])
saveas(gcf,[savedir,'M1connbar_',regionname,'.fig'])
saveas(gcf,[savedir,'M1connbar_',regionname,'.eps'],'epsc')
close
figure, bar([M2commonmat.mouse(regind,1),M2commonmat.marmoset(regind,1)])
% figure, bar(cell2mat(M2thal(:,[2,4])))
legend('mouse MOs','marmoset A6')
% xlim([0,size(M2thal,1)+1])
ylim([0 .03])
saveas(gcf,[savedir,'M2connbar_',regionname,'.fig'])
saveas(gcf,[savedir,'M2connbar_',regionname,'.eps'],'epsc')
close