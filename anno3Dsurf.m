annoregion=cell(3,1);
for i=1:R
    %     regioncolor{i}=treedata{regionids(i)}.color;
    annoregion{i}=annoimgs==regionids(i);
end
annoregionall=annoregion{1}*regionids(1)+annoregion{2}*regionids(2)+annoregion{3}*regionids(3);
%%
annoregionall1=annoimgs;
%%
corimgsurf=zeros(H1,W1);
for z=1:N1
%     corimg=double(squeeze(annoregionall1(:,N1-z+1,:))); % from caudal to rostral
corimg=double(squeeze(annoregionall1(:,z,:))); % from rostral to caudal
    corimgsurf=corimgsurf+corimg-(corimg>0&corimgsurf>0).*corimgsurf;
end
corimgsurf=flip(corimgsurf,1);
for i=1:R
    bwcoredge{i}=bwboundaries(corimgsurf==regionids(i));
    for k=1:length(bwcoredge{i})
        if size(bwcoredge{i}{k},1)>2
            regioncor{i}{k}=polyshape(bwcoredge{i}{k});
        end
    end
end
%%
sagimgsurf=zeros(H1,N1);
for w=round(W1/2):W1
    sagimg=double(squeeze(annoregionall1(:,:,w)));
    sagimgsurf=sagimgsurf+sagimg-(sagimg>0&sagimgsurf>0).*sagimgsurf;
end
sagimgsurf=flip(sagimgsurf,1);
sagimgsurf=flip(sagimgsurf,2);
for i=1:R
    bwsagedge{i}=bwboundaries(sagimgsurf==regionids(i));
    for k=1:length(bwsagedge{i})
        if size(bwsagedge{i}{k},1)>2
            regionsag{i}{k}=polyshape(bwsagedge{i}{k});
        end
    end
end
%%
transimgsurf=zeros(N1,W1);
for h=round(H1/2):H1
    transimg=double(squeeze(annoregionall1(h,:,:)));
    transimgsurf=transimgsurf+transimg-(transimg>0&transimgsurf>0).*transimgsurf;
end
transimgsurf=imrotate(transimgsurf,-90);
for i=1:R
    bwtransedge{i}=bwboundaries(transimgsurf==regionids(i));
    for k=1:length(bwtransedge{i})
        if size(bwtransedge{i}{k},1)>2
            regiontrans{i}{k}=polyshape(bwtransedge{i}{k});
        end
    end
end