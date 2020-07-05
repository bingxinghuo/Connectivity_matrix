%% injectdet_marmoset.m
% by Bingxing Huo, June 2020
% This script runs the injection detection pipeline for marmoset data,
% where injection areas were detected based on downsampled fluorescent
% image intensity.
%% 0. initialize and set parameters
species='marmoset';
detecttype='inject';
tracer='multiple';
modality='mba';
summary_initialize;
%  uiopen([savedir0,'/marmosetdatainfo.xlsx'],1);
% marmosetdatainfo=table2struct(marmosetdatainfo);
% save('marmosetdatainfo','marmosetdatainfo')
load([savedir0,'/marmosetdatainfo.mat']);
N=length(marmosetdatainfo);
%%
% myCluster = parcluster('local'); % cores on compute node to be "local"
% poolobj=parpool(myCluster, 10);
% addpath(genpath('~/scripts/'))
for i=2:N % m819 was manually annotated. Start from 2.
    %% 1. initialize
    brainID=marmosetdatainfo(i).animalid{1};
    rangeofinterest=''; % default to the entire range
    % update datainfo based on individual brain
    datainfo.animalid=brainID;
    datainfo.bitinfo=marmosetdatainfo(i).bitinfo;
    injcolor=datainfo.signalcolor;  % default to all colors
    datainfo.flips=str2num(marmosetdatainfo(i).flips);
    cell_init_marmoset_brain;
    %% 2.  set background standard
%     bgfile=[regdir,'/background_standard.mat'];
%     if exist(bgfile,'file')
%         load(bgfile); % load bgimgmed0 from contrastadj3.m
%     else
%         bgfile=[injmaskdir,'/background_standard.mat'];
%         if exist(bgfile,'file')
%             load(bgfile); % load bgimgmed0 from contrastadj3.m
%         else
%             % contrastadj3.m
%             [~,bgimgmed0,~]=bgstandard(filelist,simgdir,tissuemaskdir,injmaskdir);
%         end
%     end
%     %% 3. injection detection and summarize
%     cd(simgdir)
%     datainfo.originresolution=marmosetdatainfo(i).originresolution*maskscale;
%     for f=1:length(filelist)
%         [~,filename,~]=fileparts(filelist{f});
%         disp(['Processing ',filename,'...'])
%         maskfile=[tissuemaskdir,filename,'.tif'];
%         if ~exist(maskfile,'file')
%             maskfile=[tissuemaskdir,'imgmaskdata_',num2str(f)];
%         end
%         imgmask=imread(maskfile);
%         injmaskfile=[injmaskdir,filename,'.tif'];
%         injection_extent(filename,imgmask,bgimgmed0,injcolor,injmaskfile);
%         disp([filelist{f},' done.'])
%     end
%     %     [injdir,~,~]=fileparts(injmaskdir); % remove "/" on the end
%     neurondensity=neuronvoxelize(datainfo,tissuemaskdir,injmaskdir,savetmpdir,1,detecttype);
    %     regionneuronsummary(datainfo,detecttype,outputdir,neurondensity,annoimgfile,marmosetlistfile);
    % delete(poolobj)
    load(outputfile,'neurondensity')
    voltif=[savetmpdir,'/',brainID,'_',detecttype,'_',num2str(datainfo.voxelsize(1)),'.tif'];
    neurondensityvol=volume_reconstruct(brainID,neurondensity*(datainfo.voxelsize(1)^2),regdir,voltif,datainfo.flips);
%     outputfile=[savetmpdir,'/',brainID,'_',detecttype,'_',num2str(datainfo.voxelsize(1)),'.mat'];
    outputfile=[outputdir,'/',brainID,'_',detecttype,'_',num2str(datainfo.voxelsize(1)),'.mat'];
    save(outputfile,'neurondensityvol','-append')
    disp('Stop here to proofread.')
    return
    %% 4. proofread
    % assist proofreading
    neurondensityproof=cell(length(neurondensityvol),1);
    for c=1:length(neurondensityvol)
        neurondensityproof{c}=inject_proof(neurondensityvol{c},3,0,1); % depending on the volume, could be the first or second largest connected object
%         neurondensityproof{c}=neurondensityvol{c}>0;
        voltifi=[savetmpdir,'/',brainID,'_',detecttype,'_',num2str(datainfo.voxelsize(1)),'_',num2str(c),'_forproof.tif'];
        saveimgstack(uint8(neurondensityproof{c})*255,voltifi);
    end
    % After proofreading, apply the proofread mask to original density
    
    clear proofmask
    C=input('Please identify the channels that are proofread (1: R, 2: G, 3: B; e.g. "[1,2]"): ');
    for ci=1:length(C)
        proofreadfile=input(['Please identify the proofread mask file for channel ',num2str(C(ci)),': '],'s');
        for k=1:size(neurondensityvol{1},3)
            proofmask(:,:,k)=imread(proofreadfile,k);
        end
        densityM=neurondensityvol{C(ci)};
        neurondensityproof{C(ci)}=densityM.*cast(proofmask>0,'like',densityM);
    end
    save(outputfile,'neurondensityproof','-append')
    %% 5. Transform into atlas space
    % Current workflow (updated 4/21/2020)
    % 1. identify the result to be transformed (e.g. m921_mapinject_2_clean.tif)
    % 2. Run “python result_to_registered_flip.py $resultfile $atlasfile $outputfile” on local machine 
    %   e.g. python /Users/bingxinghuo/Documents/GITHUB/Registration_marmoset/result_to_registered_flip.py 
    %       /Users/bhuo/Dropbox\ \(Mitra\ Lab\)/Data\ and\ Analysis/Marmoset/Connectivity/M821/Cell_Detection/m821_inject_80.mat 
    %       /Users/bhuo/Dropbox\ \(Mitra\ Lab\)/Data\ and\ Analysis/Marmoset/Connectivity/M821/Registration/M821_fluoro_STS_padded.img 
    %       /Users/bhuo/m821/m821_inject_80.img
    % 3. Transfer the result ANALYZE files to BNB
    % 4. identify animal ID: "export targetnumber=M921"
    % 5. Run “register_to_atlas.sh” on BNB
    %   e.g. ~/scripts/shell_script/register_to_atlas.sh M821 m821_inject_80_2.img
    %% Marmoset: after transforming into atlas space, save the variables
    clear injdensityatlas
    outputvoxel=datainfo.voxelsize(1);
    for c=1:length(neurondensityvol)
        if ~isempty(neurondensityproof{c})
            injimgatlas=[outputdir,'/',brainID,'_',detecttype,'_',num2str(outputvoxel),'_',num2str(c),'_inatlas.img'];
            injdensityatlas(:,:,:,c)=analyze75read(injimgatlas);
            %     injdensityatlas{c}=double(injdensityatlas)/(outputvoxel^2);
        end
    end
    save(outputfile, 'injdensityatlas','-append')
    %% 5. convert injection soma into convex hull
    injmaskatlas=false(size(injdensityatlas)); % same size as the atlas for each channel
    if sum(sum(sum(sum(injdensityatlas))))>0
        disp('Converting injection soma into injection mask...')
        injhullinfo=cell(VC,1);
        % 2D convex hull
        if VC==1
            C=1;
        else
            C=signalcolor;
        end
        for c=C
            [injmaskatlas(:,:,:,c),injhullinfo{c}]=injsoma2mask(logical(injdensityatlas(:,:,:,c))); % remove the cell density information here
        end
        disp('Injection mask volume generated.')
        if sum(sum(sum(sum(injmaskatlas))))>0
            disp('Saving injection mask volume in atlas space...')
            save(outputfile,'injmaskatlas','injhullinfo','-append')
            disp('Injection mask volume in atlas space saved.')
        end
    end
    %% 6. region summary
    % injection mask region summary
    disp('Mapping the injection mask volume to the atlas...')
    
    injsummary=cell(length(signalcolor),1);
    if VC==1
        C=1;
    else
        C=signalcolor;
    end
    for c=C
        if sum(sum(sum(injmaskatlas(:,:,:,c))))>0
            summaryfile=[outputdir,'/',brainID,'_inject_',num2str(datainfo.voxelsize(1)),'_regionsummary_',colors{datainfo.signalcolor(c)},'.csv'];
            [injsummary{c}(:,1),injsummary{c}(:,2),injsummary{c}(:,3)]=region_density_list(double(squeeze(injmaskatlas(:,:,:,c)))*(datainfo.voxelsize(1)/1000)^3,atlas,summaryfile,animallist);
            injcenter=round(injhullinfo{c}.com);
            injcenterid=atlas(injcenter(1),injcenter(2),injcenter(3));
            if injcenterid>0
                disp([colors{datainfo.signalcolor(c)},' channel injection centers at:'])
                if injcenterid>10000
                    disp('Right hemisphere')
                childreninfo(animallist,injcenterid-10000,1);
                elseif injcenterid<10000
                    childreninfo(animallist,injcenterid,1);
                else
                    disp('Midline')
                end
            end
        end
    end
    save(outputfile,'injsummary','-append')
    disp('Brain region summary of injection mask volume generated.')
   
    %% 7. save injection mask tif in 80µm
    disp('Saving injection mask in tif in 80µm...')
    clear injmaskatlas_80
    injmaskfile=[outputdir,brainID,'_inject_80_atlas.tif'];
    saveimgstack(uint8(injmaskatlas),injmaskfile);
    disp('Injection mask in 80µm atlas space saved in tif.')
    %% End
    disp(['Finished processing ',brainID,' at '])
    disp(datetime('now'))
    
    %     catch
    %         disp(['Dropped (',num2str(i),') ',brainID,' at '])
    %         datetime('now')
    %     end
end
