%% braintree.m
% This script assembles the JSON hierarchical structure from Hashikawa atlas
%% 1. region's layer, full name, and abbreviation are stored in Hashikawa_regions.xlsx, sheet 2
Fulllist_header={'Layer','Abbreviation','fullname','region_id','parent','Parent_idnum','color'};
%% 2. match brain id number with name
treedata=loadjson('regions.json');
Nregions=length(treedata);
for i=1:Nregions
    id=treedata{i}.id;
    id=strtrim(id);
    idN=str2num(treedata{i}.id_num);
    
    idx=find(strcmp([Fulllist(:,2)],id));
    if isempty(idx)
        id(strfind(id,'_'))='/';
        idx=find(strcmp([Fulllist(:,2)],id));
    end
%     if isempty(idx)
%         id(strfind(id,'/'))='-';
%         idx=find(strcmp([Fulllist(:,2)],id));
%     end
%     if isempty(idx)
%         id(strfind(id,'-'))=' ';
%         idx=find(strcmp([Fulllist(:,2)],id));
%     end
    Fulllist{idx,4}=idN;
end
%% 3. Find each region's parent
Ntree=size(Fulllist,1); % number of brain regions
L=max([Fulllist{:,1}]); % number of layers in the hierarchy
% initialize
parents=cell(L,1); % initialize a cell array to contain the parent abbreviations
parentsid=zeros(L); % initialize a vector to contain the parent id number
% let 'whole bran' be its own parent
parents{1}=Fulllist{1,2}; 
parentsid(1)=Fullist{1,4};
% add two columns to the list ('parent','Parent_idnum')
Fulllist=[Fulllist,cell(Ntree,2)];
% take advantage of the data that layers are continuously arranged
for i=1:Ntree
    while isempty(Fulllist{i,5})
        for k=1:9 % check which layer it belongs to
            if Fulllist{i,1}==k-1 % layer starts from 0
                 % assign parent to this structure
                Fulllist{i,5}=parents{k};
                Fulllist{i,6}=parentsid(k);
                % set this as the parent for next layer
                parents{k+1}=Fulllist{i,2}; 
                parentsid(k+1)=Fulllist{i,4}; 
            end
        end
    end
end
%% 4. match color in Hashikawa atlas to each region
load('hashikawa_atlas_annotation.mat')
N=(length(R)-1)/2+1; % isolate 'WHOLE BRAIN' and get only one hemisphere
rgb=[R,G,B];
rgb=rgb(1:N,:);
Index=Index(1:N);
% find the labeled parts
labelnum=find(sum(rgb,2)); % find the labeled index in the atlas
% find the labeled index in the Fulllist
for i=1:length(labelnum)
    labelnum(i,2)=find([Fulllist{:,4}]==Index(labelnum(i))); 
end
% add color
for i=1:size(labelnum,1)
    Fulllist{labelnum(i,2),7}=rgb(labelnum(i,1),:)/255;
end
%% 5. save the full list
% jsontree=cell(Ntree,1);
% for i=1:Ntree
% jsontree{i}=struct('parent_num',Fulllist{i,1},'parent',Fulllist{i,5},'id_num',Fulllist{i,4},'id',Fulllist{i,2},'full_name',Fulllist{i,3});
% end
jsontree=struct(Fulllist_header{1},Fulllist(:,1),Fulllist_header{2},Fulllist(:,2),Fulllist_header{3},Fulllist(:,3),...
    Fulllist_header{4},Fulllist(:,4),Fulllist_header{5},Fulllist(:,5),Fulllist_header{6},Fulllist(:,6),...
    Fulllist_header{7},Fulllist(:,7));
savejson('Whole Brain',jsontree(2:end,:),'Filename','region_v2.json');
save('regionlist.mat','Fulllist','Fulllist_header')
%% something extra
% %% Find parent id numbers
% % 1. add id numbers for entries with no id number
% allnum=[Fulllist{:,4}];
% emptynum=find(cellfun(@isempty,Fulllist(:,4)));
% emptynum(:,2)=max(allnum)+1:max(allnum)+size(emptynum,1);
% for i=1:size(emptynum,1)
%     Fulllist{emptynum(i),4}=emptynum(i,2);
% end
% % 2. assign parent id numbers
% for i=1:Ntree
%     parentid=find(strncmp(Fulllist(i,5),Fulllist(:,2),5));
%     Fulllist{i,6}=Fulllist{parentid,4};
% end
