%% projvoxelize.m
% Bingxing Huo, Aug 2019
% This script takes the processes detection results and convert it into
% voxelized density
% Note that the output may have 1 row and/or 1 column more than the
% annotation volume. The last row/column can be removed in these cases.
function neurondensity=voxel_density_volume(imgdir,neurondir,savedir,M,procbug)
%---to be removed in future---%
if nargin<5
    procbug=0;
end
%---------------------------
cd(neurondir)
filelist=filelsread('*.tif',savedir);
parfor f=1:length(filelist)
    try
        neuronmask=imread(filelist{f}); % processes detection results
        origimg=imread([imgdir,filelist{f}(1:end-3),'jp2']); % original data
    catch % in case of jp2 conversion failed, load tif
        origimg=imread([imgdir,filelist{f}(1:end-13),'.tif']);
    end
    %----------------
    if procbug==1
        [H,W]=size(neuronmask);
        tilex=512;
        % This part was added due to a bug in processes detection
        % force edges to be 0
        neuronmask(:,1)=0;
        neuronmask(:,W)=0;
        neuronmask(1,:)=0;
        neuronmask(H,:)=0;
        % force tile edges to 0
        for h=1:floor(H/tilex)
            for w=1:floor(W/tilex)
                neuronmask(h*tilex:h*tilex+1,w*tilex:w*tilex+1)=0;
            end
        end
    end
    %---------------
    % downsample to atlas resolution
    tifimgdown=downsample_m(double(neuronmask),M,'sum');
    % generate mask
    jp2imgdown=downsample_m(origimg,M,'mean');
    imgmask=cropmask(jp2imgdown);
    neuronmaskval=unique(neuronmask);
    neuronmaskval=max(neuronmaskval); % mask value
    neurondensity(:,:,f)=tifimgdown.*imgmask/neuronmaskval/(M^2); % calculate density
end