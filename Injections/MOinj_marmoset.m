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
injretro=u