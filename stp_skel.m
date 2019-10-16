% skel=load_v3d_swc_file('all-annoatated-bh.tif_smartTracing.swc');
skel=load_v3d_swc_file('stree_PMD1476.swc');
% [W,H,D]=size(neurondensity);
neuronc=round(skel(:,[4,3,5,6]));
for d=1:D
    neuronimg=uint8(zeros(H,W));
    neuronplane=neuronc(find(neuronc(:,3)==d),:);
    if ~isempty(neuronplane)
        for k=1:size(neuronplane,1)
            tempbw=zeros(H,W);
            tempbw(neuronplane(k,1),neuronplane(k,2))=1;
            tempbw=imdilate(tempbw,strel('disk',round(neuronplane(k,4)*3)));
            neuronimg=neuronimg+uint8(tempbw*255);
        end
    end
    if d==1
        imwrite(neuronimg,['DMskel.tif'],'writemode','overwrite','compression','none')
    else
        imwrite(neuronimg,['DMskel.tif'],'writemode','append','compression','none')
    end
end
%%
% N=length(imfinfo('180830_downsample_regANNO_25.tif'));
for n=1:N
%     annomap(:,:,n)=imread('180830_downsample_regANNO_25.tif',n);
    neuronskel(:,:,n)=imread('DMskel.tif',n);
end
% annomap1=flip(annomap,2);
[W,H,D]=size(annomap1);
neuronskel1=neuronskel(1:W,1:H,1:D);
skelregionvol=annomap1.*cast(neuronskel1>0,'like',annomap1);
skelregionids=nonzeros(unique(skelregionvol));
for s=1:length(skelregionids)
    skelregionids(s,2)=sum(sum(sum(skelregionvol==skelregionids(s))));
end
[~,isort]=sort(skelregionids(:,2),'descend');
skelregionids=skelregionids(isort,:);