% construct a brain hierarchy matrix
%%
greyind=[1,4,9]; % rows in partid
greybranch=cell(3,1);
greybranchmat=cell(3,1);
greybranchname=cell(3,1);
for i=1:3
    g=greyind(i);
    L_g=~cellfun(@isempty,partid(g,2:end)); % check how many layers in each row
    L_g=sum(L_g); % set the upper threshold
    branch=cell(1,L_g);
    branch{1}=partid{g,2}(:,1);
    block=cell(3,1);
    for l=2:L_g
        % fill all the empty branches
        branch{l}=branch{l-1}; % pre-fill all the layers
        branch{l}(:,2)=1:size(branch{l},1); % keep record of index
        Nregion=size(partid{g,l},1); % number of regions in the previous layer
        % expand the current layer
        for n=1:Nregion
            ind=find(partid{g,l+1}(:,2)==n); % look for branches under the same node
            nnew=find(branch{l}(:,2)==n); % look for the new location for expansion
            if ~isempty(ind)
                if nnew==1
                    block{1}=[];
                else
                    block{1}=branch{l}(1:nnew-1,:);
                end
                block{2}=partid{g,l+1}(ind,:);
                if nnew==size(branch{l},1)
                    block{3}=[];
                else
                    block{3}=branch{l}(nnew+1:end,:);
                end
                branch{l}=cell2mat(block);
            end
        end
    end
    greybranch{i}=branch;
    %
    branch1{L_g}=branch{L_g};
    for l=1:L_g-1
        reps=accumarray(branch1{L_g+1-l}(:,2),1);
        branch1{L_g-l}=[];
        for n=1:size(branch{L_g-l},1)
            branch1{L_g-l}=[branch1{L_g-l};repmat(branch{L_g-l}(n,:),reps(n),1)];
        end
    end
    for l=1:L_g
        branch1mat(:,l)=branch1{l}(:,1);
    end
    greybranchmat{i}=branch1mat;
    % names
    greybranchname{i}=cell(size(branch1mat));
    for n=1:max([Fulllist{:,4}])
        nind=find([Fulllist{:,4}]==n);
        greybranchname{i}(branch1mat==n)=Fulllist(nind,3);
    end
    clear branch1 branch1mat
end
%
