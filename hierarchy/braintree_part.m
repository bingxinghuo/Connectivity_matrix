%% braintree_part.m
% This script generates JSON structure as a subset of the full brain region
% hierarchy
load regionlist % output from braintree.m
%%
partid=brainlayers(Fulllist);
N1=size(partid,1); % number of top tier structures
L=max([Fulllist{:,1}]); % number of layers in the hierarchy
%% Consolidate all the sub-structures under each layer 1 structures
partid_all=[partid(:,1),cell(N1,2)];
% 1. Column 2 contains the brain part id (in one row)
for i=1:N1 % separates according to brain parts at layer 1
    partid_all{i,2}=[];
    for j=1:L % go over each layer
        partid_all{i,2}=[partid_all{i},partid{i,j}]; 
    end
end
% 2. Column 3 contains the index of those brain parts in Fulllist
for i=1:N1
    Nparts=length(partid_all{i,2});
    partind=zeros(1,Nparts);
    for j=1:Nparts
        partind(j)=find([Fulllist{:,4}]==partid_all{i,2}(j));
    end
    partid_all{i,3}=partind;
end
%% Specify a subset of the top layers
partialtop=[1,4,5,9];
% see what they are
partid(partialtop,1)
% Get all structures and substructures 
partiallist=[];
for i=1:length(partialtop)
    partiallist=[partiallist;Fulllist(partid_all{partialtop(i),3},:)];
end
%% select the labeled parts to save
labelnum=find(~cellfun(@isempty,Fulllist(:,7))); % labeled = color coded
labellist=Fulllist(labelnum,:);
jsontree=struct(Fulllist_header{1},labellist(:,1),Fulllist_header{2},labellist(:,2),Fulllist_header{3},labellist(:,3),...
    Fulllist_header{4},labellist(:,4),Fulllist_header{5},labellist(:,5),Fulllist_header{6},labellist(:,6),Fulllist_header{7},labellist(:,7));
savejson('Whole Brain',jsontree(2:end,:),'Filename','labelregion_v3.json');
%% sanity check: which top layer do these labeled areas belong to
Index_labeled=labelnum; % Column 1 saves the index of the labeled structures in full list
Index_labeled(:,2)=Index(labelnum); % Column 2 saves the brain id of labeled parts
for i=1:size(labelnum,1)
    for p=1:N1 % for each top tier structure
        n=find(ismember(partid_all{p,2},Index_labeled(i,2)));
        if ~isempty(n)
           Index_labeled(i,3)=p; % which top layer it belongs to
           Index_labeled(i,4)=n; % the index within this top layer
        end
    end
end
toplabel_ind=nonzeros(Index_labeled(:,3));
% check how many structures are labeled
for i=1:N1
    [i,sum(toplabel_ind==i)]
end
%% Combine labeled and desired top layer structures
Index_labeled(:,5)=ismember(Index_labeled(:,3),partialtop); % check if it belongs to the desired top layers 
% pull all info from the Fulllist
part_label_ind=find(Index_labeled(:,1).*Index_labeled(:,5));
part_label_list=Fulllist(labelnum(part_label_ind,2),:);
% add higher layer regions in the tree
part_label_list=[Fulllist(1,:);part_label_list]; % add whole brain
%% Complete the hierarchy by adding missing links 
% check if the hierarchy is self-contained
mispartid=[];
k=1;
for i=1:size(part_label_list,1)
    if ~ismember(part_label_list(i,5),part_label_list(:,2))
%         disp(['Missing ',part_label_list(i,5)])
        mispartid(k)=part_label_list{i,6};
        k=k+1;
    end
end
% add missing parts
mispartidu=unique(mispartid');
for i=1:size(mispartidu,1)
mispartidu(i,2)=find([Fulllist{:,4}]==mispartidu(i,1));
end
part_label_list=[part_label_list;Fulllist(mispartidu(:,2),:)];
% sort by the id number
part_label_list=sortrows(part_label_list,4);
%% save
jsontree=struct(Fulllist_header{1},part_label_list(:,1),Fulllist_header{2},part_label_list(:,2),Fulllist_header{3},part_label_list(:,3),...
    Fulllist_header{4},part_label_list(:,4),Fulllist_header{5},part_label_list(:,5),Fulllist_header{6},part_label_list(:,6),...
    Fulllist_header{7},part_label_list(:,7));
savejson('Whole Brain',jsontree(2:end,:),'Filename','labelregion_v4.json');