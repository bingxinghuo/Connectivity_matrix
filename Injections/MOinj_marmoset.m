%% marmoset
detecttype='cell';
species='marmoset';
tracer='FB';
modality='mba';
summary_initialize;
%%
load('allinjinfo','injanno')
regionids=[796;797]; % motor + sensory
P=length(regionids);
MOids=cell(P,1);
for p=1:P
    regioninfotmp=childreninfo(animallist,regionids(p),0);
    MOids{p}=cell2mat(regioninfotmp(:,4));
end
for t=1:length(injanno)
    for i=1:length(injanno{t})
        for p=1:P
            if ismember(injanno{t}(i,2),MOids{p})
                injanno{t}(i,3)=p;
            end
        end
    end
    injMS{t}=injanno{t}(injanno{t}(:,3)>0,:);
end
%%
brainlist1=[];
for i=1:3
    brainlist1=[brainlist1;[injMS{i}(:,1),ones(size(injMS{i},1),1)*i]];
end
brainlist11=unique(brainlist1(:,1));
L=length(brainlist);
colorind=cell(L,1);
brainlist=cell(L,1);
for i=1:L
    brainlist{i}=['M',num2str(brainlist11(i))];
    ind=find(brainlist1==brainlist11(i));
    colorind{i}=num2str(brainlist1(ind,2))';
end
%%
brainlistfile=[savedir0,'/annotatedID1.txt'];
fid=fopen(brainlistfile,'w');
fprintf(fid,'%s\n',brainlist{:});
fclose(fid);
%%
signalfile=[savedir0,'/motorinjcolor1.txt'];
fid=fopen(signalfile,'w');
fprintf(fid,'%s\n',colorind{:});
fclose(fid);