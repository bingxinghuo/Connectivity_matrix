%% wrapping script for voxelized summary of neuron detection results
% 
%% set directories
datasetID='180830_JH_WG_Fezf2LSLflp_CFA_female_processed';
% input
neurondir='~/CSHLservers/mitragpu3/disk125/main/MorseSkeleton_OSUMITRA/Samik/Results0806/results_180830M/';
jp2dir=['~/CSHLservers/mitragpu3/disk125/main/jhuangU19/level_1/',datasetID,'/stitchedImage_ch1/'];
% output
outputdir=['~/Desktop/',datasetID(1:6),'/'];
if ~exist(outputdir,'dir')
    mkdir(outputdir)
end
outputvolumefile=[outputdir,'/',datasetID(1:6),'_projdensity.tif'];
%% set parameters
atlasvoxel=50;
originvoxel=1;
dsrate=atlasvoxel/originvoxel; 
%% summarize neuron density
neurondensity=voxel_density_volume(jp2dir,neurondir,outputdir,dsrate,1);
%% save
imwrite(neurondensity(:,:,1),outputvolumefile,'WriteMode','overwrite')
for f=2:length(filelist)
    imwrite(neurondensity(:,:,f),outputvolumefile,'WriteMode','append')
end
