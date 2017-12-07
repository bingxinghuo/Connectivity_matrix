%% Anatomy-based iterative injction planning
% 1. extract layer 1 structure's volumes
% 2. assign injection points I
% 3. if I > 1, continue to the next layer
% othersie, stop.
% 4. special case: parent structure has no volume, proceed if I==0
% %% 0. load data and extract structure information
% load regionlist % output from braintree.m
% %
% partid=brainlayers(Fulllist);
% N1=size(partid,1); % number of top tier structures
% L=max([Fulllist{:,1}]); % number of layers in the hierarchy
% %%
% marmo=load_nii('LabelMap.nii');
% marmo.atlas=marmo.img;
% marmo.atlas(678/2+1:678,:,:)=marmo.atlas(678/2+1:678,:,:)-10000; % correct the right hemisphere
%% 1. Initialize
greyind=[1,4,9]; % rows in partid
mmperpix=.04*.04*.115;
% gridsize=1.756^3;
gridsize=2^3;
structure_volume=cell(3,L);
for g=1:3
    proceed=1;
    L_g=~cellfun(@isempty,partid(greyind(g),2:end)); % check how many layers in each row
    L_g=sum(L_g); % set the upper threshold
    l=0;
    while proceed==1 % proceed to next layer
        l=l+1; % take next layer as current
        regionid=partid{greyind(g),l+1}(:,1); % get all the region id's within this layer
        structure_volume{g,l}=zeros(size(regionid,1),2); % initialize the storage space
        for r=1:length(regionid) % all structures in this layer
            [~,regionpix]=regionread(marmo.atlas,regionid(r)); % extract pixels
            regionvol=regionpix*mmperpix; % volume in mm3
            regioninj=regionvol/gridsize;  % calculate injection points
            structure_volume{g,l}(r,:)=[regionid(r),regioninj]; % record region id and injection number
            % apply criteria to see whether to proceed
            if l==L_g % hard bottom branch
                proceed=0;
            end
        end
    end
end
%%
save('structurevols','structure_volume')
%% a list of injections
injvol=cell2mat(structure_volume(1,:)');
