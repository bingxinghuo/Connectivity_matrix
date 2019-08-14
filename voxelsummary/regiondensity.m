%% summarize neuron density for individual region
datasetID='180830_JH_WG_Fezf2LSLflp_CFA_female_processed';
% input
annodir='~/CSHLservers/mitragpu3/mnt/disk132/main/STP_RegistrationData/data/deformedAtlas/';
annoimgfile=[annodir,'/',datasetID(1:6),'_downsample_regANNO_50.img'];
inputdir=['~/Desktop/',datasetID(1:6),'/'];
volumefile=[inputdir,datasetID(1:6),'_projdensity.tif'];
mouselistfile='~/Documents/GITHUB/Connectivity_matrix/CCFregionlist.mat'; % lookup table
% output
outputdir=inputdir;
outputlistfile=[outputdir,'/',datasetID(1:6),'neuronregionmap.csv'];
%% load data
N=imfinfo(volumefile);
for n=1:length(N)
    neurondensity(:,:,n)=imread(volumefile,n);
end
annoimg=load_nii(annoimgfile);
annoimg=rot90(annoimg.img,2); % rotate 180 degrees
regionLUT=load(mouselistfile,'mouselist');
regionLUT=regionLUT.mouselist;
%% calculate summary density for individual region
[idsorted,densitysorted,regionsorted]=region_density_list(neurondensity,annoimg,regionLUT);
%% save
fid=fopen(outputlistfile,'w');
for i=1:length(idsorted)
    fprintf(fid,'%d,%f,%s\n',idsorted(i),densitysorted(i),regionsorted{i});
end
fclose(fid);
%% transform back to CCF space
% save
% write_vtk_image(x,y,z,I,filename,title,names);
