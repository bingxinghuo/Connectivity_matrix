%% Iterative injction planning
% 1. extract layer 1 structure's volumes
% 2. assign injection points I
% 3. if I > 1, continue to the next layer
% othersie, stop.
% 4. special case: parent structure has no volume, proceed if I==0
%% 0. load data and extract structure information
load regionlist % output from braintree.m
%
partid=brainlayers(Fulllist);
N1=size(partid,1); % number of top tier structures
L=max([Fulllist{:,1}]); % number of layers in the hierarchy
%%
marmo=load_nii('LabelMap.nii');
marmo.atlas=marmo.img;
marmo.atlas(678/2+1:678,:,:)=marmo.atlas(678/2+1:678,:,:)-10000; % correct the right hemisphere
%% 1. Initialize
greyind=[1,4,9]; % rows in partid
mmperpix=.04*.04*.115;
gridsize=1.756;
structure_volume=cell(3,L);
for g=1:3
    proceed=1;
    l=0;
    while proceed==1
        l=l+1;
        regionid=partid{greyind(g),l+1}(:,1);
        for r=1:length(regionid) % all structures in this layer
            if l==L-1 % bottom branch
                proceed=0;
            else
                [~,regionpix]=regionread(marmo.atlas,regionid); % extract pixels
                regionvol=regionpix*mmperpix; % volume in mm3
                regioninj=round(regionvol/(gridsize^3));  % calculate injection points
                subregion=find(partid{greyind(g),l+2}(:,2)==r);
                if ~isempty(subregion) % there is subregion
                    if regioninj>0 % at least 1 injection
                        structure_volume{g,l}(r,:)=[regionid(r),regioninj]; % record region id and injection number
                        proceed=1;
                    elseif regioninj==0 % no volume assigned
                        proceed = 1;
                    else % not enough volume for injection
                        proceed=0;
                    end
                else % there is no further subregion
                    proceed=0;
                end
            end
        end
    end
end