%%
% Note: the second colume in each branch layer shows the index of the
% parent layer (row number in the previous layer)
function [regionid,branches]=extractleaf(treedata)
% level 1: initialize
branches={treedata.name,0};
children=cell(1,2);
regionid=[];
children{1}=getfield(treedata,'children');
children{1}=children{1}';
children{2}=children{1};
% level 2
iter=0; % count iterations
proceed=1; % flag whether to proceed
figure, hold on
while proceed==1 % as long as the number of branches are growing
    proceed=0;
    iter=iter+1;
    children{1}=children{2}; % take the next layer as the current layer
    subN=length(children{1}); % number of nodes in the current layer
    plot(iter,subN,'o',iter,length(regionid),'*')
    drawnow
    children{2}=[];
    branches{iter}={};
    for i=1:subN % read out current layer
        children_temp=getfield(children{1}{i},'children'); % extract the next layer
        children_temp=children_temp';
        n=length(children_temp);
        if n>0 % it has children
            proceed=1; % proceed
            children_temp1=cell2mat(children_temp);
            % assemble the next layer
                branches{iter}=[branches{iter};{children_temp1.name}',num2cell(ones(n,1)*i)];
                children{2}=[children{2};children_temp];            
        else % at bottom
            regionid=[regionid;children{1}{i}.id]; % record id
            % discard the branch from subsequent processing
        end
    end    
end