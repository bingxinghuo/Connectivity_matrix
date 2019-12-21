targetdir='~/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/MotorCortex/';
% targetdir='~/Dropbox (Marmoset)/BingxingHuo/Mouse/MotorCortex/';
cd(targetdir)
neuroncount=cell(3,1);
load('MOsummary/MOinjsummary')
% load('MOsummary/MOanimalinfo')
injinfo=M1inj;
tracerinj{1}=injinfo(injinfo(:,2)<3,:);
tracerinj{2}=injinfo(injinfo(:,2)==3,:);
for t=1
    tracerinfo=tracerinj{t};
    if t==1
        detecttype='process';
    elseif t==2
        detecttype='cell';
    end
    for k=1:size(tracerinfo,1)
        i=tracerinfo(k,1);
                animalid=motorbraininfo(i).animalid;
%         animalid=animallist{i,1};
        savedir=[targetdir,'/',upper(animalid)];
        if strcmp(detecttype,'cell')
            sumfile=[savedir,'/',animalid,'_region',detecttype,'.csv'];
        else
            sumfile=[savedir,'/',animalid,'_region',detecttype,'_',num2str(tracerinfo(k,2)),'.csv'];
        end
        injectsumfile=[savedir,'/',animalid,'_regioninject_',num2str(tracerinfo(k,2)),'.csv'];
        %%
        neuronsum=readtable(sumfile);
        neuroncounts=table2array(neuronsum(:,1:2));
        noninjectid=ones(size(neuroncounts,1),1);
        if t==2
            injectsum=readtable(injectsumfile);
            injectregionid=table2array(injectsum(:,1));
            
            for j=1:length(injectregionid)
                noninjectid(neuroncounts(:,1)==injectregionid(j))=0;
            end
        end
        neuroncount{k}=neuroncounts.*(noninjectid*ones(1,2));
    end
    %% consolidate
    regionids=[];
    for k=1:size(tracerinfo,1)
        regionids=[regionids;neuroncount{k}(:,1)];
    end
    regionids=unique(nonzeros(regionids));
    regionneuron=zeros(length(regionids),size(tracerinfo,1));
    for j=1:length(regionids)
        regionid=regionids(j);
        neuronnum=0;
        for k=1:size(tracerinfo,1)
            cellind=find(neuroncount{k}(:,1)==regionid);
            if ~isempty(cellind)
                regionneuron(j,k)=neuroncount{k}(cellind,2);
            end
        end
    end
    %% assign into label bar
    load([targetdir,'/toplevelindices'],'regionlabel')
    regionsummary=regionlabel;
    for k=1:length(regionlabel)
        regionsummary{k,3}=[regionsummary{k,3},zeros(size(regionsummary{k,3},1),size(tracerinfo,1))];
    end
    for j=1:length(regionids)
        regionid=regionids(j);
        a=0;
        ind=[];
        while isempty(ind)
            a=a+1;
            if a<=size(regionlabel,1)
                ind=find(regionlabel{a,3}(:,1)==regionid);
            else
                break
            end
        end
        if ~isempty(ind)
            regionsummary{a,3}(ind,:)=[regionlabel{a,3}(ind,1),regionneuron(j,:)];
        end
    end
    neuronsorted=cell2mat(regionsummary(:,3));
    figure, imagesc(mean(neuronsorted(:,2:end),2))
    colormap hot
    %     caxis([10 1000])
    figure, imagesc(neuronsorted(:,2:end))
    colormap hot
end

%%
A=[];k=0;
for a=1:size(regionlabel,1)
    k=k+1;
    A=[A,ones(1,length(regionlabel{a,3}))*k];
end
figure, imagesc(A')