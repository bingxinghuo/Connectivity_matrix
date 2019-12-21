%% select the motor cortex neurons from the Mouse Light data
load('/Users/bhuo/Documents/GITHUB/Connectivity_matrix/CCFregionlist.mat', 'mouselist')
motorregions=childreninfo(mouselist,500,0);
motorids=cell2mat(motorregions(:,4));
% savedir='/Users/bhuo/Dropbox (Marmoset)/BingxingHuo/Computation/Skeletonization_OSU/MouseLightMO/';
% for k=2:size(motorregions,1)
%     mkdir([savedir,motorregions{k,3}])
% end
%%
mldir='/Users/bhuo/Dropbox (Marmoset)/MouseBrainExtramuralData/MouseLight/';
neuronid=[];
moregionid=[];
for i=1:48
    mlsubdir=[mldir,'Batch',num2str(i)];
    if ~exist(mlsubdir,'dir')
        mlsubdir=[mldir,'batch',num2str(i)];
    end
    jsonfile=[mlsubdir,'/mlnb-export.json'];
    if ~exist(jsonfile,'file')
        jsonfile=[mlsubdir,'/mlnb-export (',num2str(i-1),').json'];
    end
    mlinfo=loadjson(jsonfile);
    for j=1:length(mlinfo.neurons)
        neuronreginid=mlinfo.neurons{j}.soma.allenId;
        if ~isempty(neuronreginid)
            if sum(motorids==neuronreginid)>0 % belong to motor cortex
                neuronid=[neuronid;mlinfo.neurons{j}.idString];
                moregionid=[moregionid;neuronreginid];
            end
        end
    end
end
