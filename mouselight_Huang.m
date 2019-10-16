addpath(genpath('/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Mouse/Standard IO/conversion_scripts'))
swcdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Mouse/MotorCortex/MouseLight_MOp5/';
mlid={'AA0927';'AA0926';'AA0923'};
for n=1:3
ml{n} = load_v3d_swc_file([swcdir,mlid{n},'.swc']);
end
stpdir='/Users/bingxinghuo/Dropbox (Marmoset)/BingxingHuo/Mouse/BICCN/Huang U19/180830/';
stpatlas=load_nii([stpdir,'/180830_atlas_50.img']);
stpimg=stpatlas.img;
% ------ temporary fix orientation ---
stpimg1=permute(stpimg,[2,3,1]);
stpimg1=flip(stpimg1,1);
% 10 pixel padding in 50um volume of stp mapping to atlas space
% extract the coordinates to match the stp map
neuron=cell(3,1);
neuronc=cell(3,1);
for n=1:3
    neuron{n}=ml{n}(:,3:5)/50+10; % swc coordinates are in microns
    neuronc{n}=round(neuron{n});
end
[H,W,D]=size(stpimg1);
for d=1:D
    if d<=10
        %     stpsec=single(zeros(H,W));
        neuronimg=uint8(zeros(H,W));
        for n=1:3
            if d==1
                imwrite(neuronimg,['neuron_',mlid{n},'.tif'],'writemode','overwrite','compression','none')
            else
                imwrite(neuronimg,['neuron_',mlid{n},'.tif'],'writemode','append','compression','none')
            end
        end
    else
        stpsec=stpimg1(:,:,d);
        neuronplane=cell(3,1);
        for n=1:3
            neuronplane{n}=neuronc{n}(find(neuronc{n}(:,3)==d),:);
            neuronimg=uint8(zeros(H,W));
            if ~isempty(neuronplane{n})
                for k=1:size(neuronplane{n},1)
                    neuronimg(neuronplane{n}(k,1),neuronplane{n}(k,2))=255;
                end
            end
            imwrite(neuronimg,['neuron_',mlid{n},'.tif'],'writemode','append','compression','none')
        end
        
    end
end
%%
D=length(imfinfo('neuron_AA0923.tif'))
for d=1:D
neuron927(:,:,d)=imread('neuron_AA0927.tif',d);
end
neuron927=neuron927(11:end-10,11:end-10,11:end-10);
annoimg=nhdr_nrrd_read('annotation_50.nrrd',1);
annoimg=permute(annoimg.data,[3,2,1]);
%%
% neuronskel1=neuronskel(1:W,1:H,1:D);
% neuronskel1=neuron926;
skelregionvol=annoimg.*uint32(neuronskel1>0);
skelregionids=nonzeros(unique(skelregionvol));
for s=1:length(skelregionids)
    skelregionids(s,2)=sum(sum(sum(skelregionvol==skelregionids(s))));
end
[~,isort]=sort(skelregionids(:,2),'descend');
skelregionids=skelregionids(isort,:);