function partid=brainlayers(Fulllist)
%% Separate different parts of the brain
k=1;
layer=1;
partid=cell(1);
Ntree=size(Fulllist,1);
for i=1:Ntree
    if Fulllist{i,1}==layer % get the top layer
        partid{k,1}=Fulllist{i,4}; % get the top layer id number
        %         partid{k,2}=Fulllist{i,2}; % get the layer abb. name
        k=k+1;
    end
end
%% Find all the substructures
L=max([Fulllist{:,1}]); % number of layers in the hierarchy
for layer=2:L % layer defines the columns
    for i=1:size(partid,1) % for each top level (row)
        partid{i,layer}=[]; % initialize the cell entry
        upperlayer=partid{i,layer-1}; % get the previous layer id's
        if ~isempty(upperlayer)
            for j=1:length(upperlayer) % go to the next layer
                idnum=find([Fulllist{:,6}]==upperlayer(j)); % find all the next layer id
                if ~isempty(idnum)
                    partid{i,layer}=[partid{i,layer},[Fulllist{idnum,4}]]; % consolidate all the structures within the same layer
                end
            end
        end
    end
end
%% sanity check 1
N1=size(partid,1);
for i=1:N1
    for j=1:L
        Anum(i,j)=size(partid{i,j},2);
    end
end
sum(sum(Anum))
%% sanity check 2
toplayerind=zeros(N1,1);
for i=1:N1
    toplayerind(i)=find([Fulllist{:,4}]==partid{i,1});
end
toplayer=Fulllist(toplayerind,:);
partid=[Fulllist(toplayerind,3),partid];