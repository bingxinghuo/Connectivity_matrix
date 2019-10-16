targetdir='~/Dropbox (Marmoset)/BingxingHuo/Mouse/MotorCortex/';
cd(targetdir)
% fid=fopen('MOanimalinfo.txt');
% animallist=textscan(fid,'%s');
% fclose(fid);
% animallist=animallist{1};
load('MOanimalinfo.mat')
N=size(animallist,1);
%%
mouselistfile='~/Documents/GITHUB/Connectivity_matrix/CCFregionlist.mat';
load(mouselistfile)
%%
for n=4:N
    tic;
    animalid=animallist{n,1};
    disp(['Processing ',animalid,'...'])
    savedir=[targetdir,'/',animalid];
    % load annotation
    annoimgfile=[savedir,'/deformedAtlas.img'];
    annostack=load_nii(annoimgfile);
    % use registered atlas as mask
    maskfile=[savedir,'/deformedAtlas_mask.tif'];
    if ~exist(maskfile,'file')
        annomask=annostack.img>0;
        imwrite(annomask(:,:,1),maskfile,'writemode','overwrite','compression','none')
        for i=2:size(annomask,3)
            imwrite(annomask(:,:,i),maskfile,'writemode','append','compression','none')
        end
    else
        clear annomask
        imginfo=imfinfo(maskfile);
        for i=1:length(imginfo)
            annomask(:,:,i)=imread(maskfile,i);
        end
    end
    channels=animallist{n,2};
    for c=1:length(channels)
        if channels(c)==1
            channelID='R';
        elseif channels(c)==2
            channelID='G';
        end
        processvolfile=[savedir,'/RegisteredProcess',channelID,'_cleanup.img'];
        if ~exist(processvolfile,'file')
            processvolfile=[savedir,'/RegisteredProcess',channelID,'.img'];
        end
        processvol=load_nii(processvolfile);
        annomask=cast(annomask,'like',processvol.img);
        processvolimg=processvol.img.*annomask;
        outputlistfile=[savedir,'/',animalid,'_regionprocess_',num2str(channels(c)),'.csv'];
        region_density_list(processvolimg,annostack.img,outputlistfile,mouselist);
    end
    toc;
    disp('Done.')
end