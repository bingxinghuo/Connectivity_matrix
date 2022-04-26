%% 0. initialize and set parameters
species='marmoset';
detecttype='inject';
tracer='multiple';
modality='mba';
summary_initialize;
%  uiopen([savedir0,'/marmosetdatainfo.xlsx'],1);
% marmosetdatainfo=table2struct(marmosetdatainfo);
% save('marmosetdatainfo','marmosetdatainfo')
% load([savedir0,'/marmosetdatainfo.mat']);
load('~/Dropbox (Mitra Lab)/BingxingHuo/ComparativeAnatomy/SC/marmoset/SCmarmosetdatainfo.mat')
marmosetdatainfo=SCmarmosetinfo;
N=length(marmosetdatainfo);
%%
myCluster = parcluster('local');
poolobj=parpool(myCluster, 10);
for i=1:N
    %% 1. initialize
    brainID=marmosetdatainfo(i).animalid{1};
    rangeofinterest=marmosetdatainfo(i).injrange;
    % update datainfo based on individual brain
    datainfo.animalid=brainID;
    datainfo.bitinfo=marmosetdatainfo(i).bitinfo;
    injcolor=datainfo.signalcolor;  % default to all colors
    datainfo.flips=str2num(marmosetdatainfo(i).flips);
    %     cell_init_marmoset_brain;
    outputdir=[savedir0,'/',brainID,'/Cell_Detection/'];
    mkdir([outputdir,'injmask1'])
    imgdir=[imgdir0,lower(brainID),'/',lower(brainID),'F/JP2/']; % unregistered images
    cd(imgdir)
    filelist=filelsread('*.jp2','~/',3);
    parfor f=1:length(filelist)
        [~,filename,~]=fileparts(filelist{f});
        disp(['Processing ',filename,'...'])
        imgmask=imread([outputdir,'injmasks/',filename,'.tif']);
        imgsize=imfinfo(filelist{f});
        imgmask1=uint8(zeros(imgsize.Height,imgsize.Width,3));
        for c=1:2
            if f>=rangeofinterest(c,1) && f<= rangeofinterest(c,2)
                maskup=imresize(imgmask(:,:,c),[imgsize.Height,imgsize.Width]);
                imgmask1(:,:,c)=maskup;
            end
        end
        if f>=rangeofinterest(3,1) && f<= rangeofinterest(3,2)
            bluemask=imgmask>0;
            %             bluemask=bluemask(:,:,1).*bluemask(:,:,2).*bluemask(:,:,3);
            bluemask=bluemask(:,:,2).*bluemask(:,:,3);
            maskup=imresize(bluemask*255,[imgsize.Height,imgsize.Width]);
            imgmask1(:,:,3)=maskup;
        end
        imwrite(imgmask1,[outputdir,'injmask1/',filename,'.tif']);
    end
    
end
delete(poolobj)