%% connmatsummary.m
% This script consolidates the connectiviy matrix across animals and save
% into a matrix format
% Note: this script so far is designed for motor cortex injection. To
% update, modify the output variable names. 
% input:
%   - targetdir: directory that contains involved animal's voxelized
%   summary in subfolders
%   - injinfoind: generated from injinfoind_gen, 2-by-1 cell. Cell 1
%   contains the M1 injection cases; Cell 2 contains the M2 injection
%   cases. Within each cell, a N-by-3 matrix containing all integers.
%   Column 1 is the index of animal ID in the MOanimalinfo.mat; Column 2 is
%   the channel index that contains a tracer; Column 3 is the tracer type,
%   where 1 - anterograde and 2 - retrograde. 
%   - outputdir: directory with writing permission to save the output
%   matrix and figures.
%   - topregionlabel: depending on the species. Mouse:
%   'Github/DAP/Process_Detection/voxelsummary/toplevelindices.mat'.
%   Marmoset: 'Github/Connectivity_matrix/toplevelindices.mat'. 
%   - visfig: optional. If requires visual output, set to 1. 
% output:
%   - matrices containing the sorted neuron summary output, saved in mat file. Column 1 is the
%   region name. All regions are sorted according to the top label. For all
%   other columns, each column contains the percentage neuron density in
%   each region in each animal. 
function connmatsummary_2019(targetdir,injinfo,outputdir,topregionlabel,visfig)
% targetdir='~/Dropbox (Marmoset)/BingxingHuo/Marmoset Brain Architecture/MotorCortex/';
% targetdir='~/Dropbox (Marmoset)/BingxingHuo/Mouse/MotorCortex/';
cd(targetdir)
% neuroncount=cell(3,1);
% load('MOsummary/MOinjsummary')
% load('MOsummary/MOanimalinfo')
% load([targetdir,'/',injinfofile],'Minj')
% injinfo=Minj;
% tracerinj{1}=injinfo(injinfo(:,2)<3,:);
% tracerinj{2}=injinfo(injinfo(:,2)==3,:);
for r=1:2 % separate M1 and M2 injections
    types=unique(injinfo{r}(:,3)); % third column contains tracer type information
    for i=1:length(types)
        t=types(i);
        if t==1 % anterograde
            detecttype='process';
        elseif t==2 % retrograde
            detecttype='cell';
        end
        tracerinfo=injinfo{r}(injinfo{r}(:,3)==t,:); % choose one tracer type at a time
        neuroncount=cell(size(tracerinfo,1),1);
        for k=1:size(tracerinfo,1)
            animalid=motorbraininfo(tracerinfo(k,1)).animalid;
            %         animalid=animallist{i,1};
            savedir=[targetdir,'/',upper(animalid)];
            sumvol=[savedir,'/',animalid,'_map',detecttype,'.mat'];
            neuronsumvol=load(sumvol);
            neuronvol=neuronsumvol.mapvol;
            annovol=neuronsumvol.annoimgs;
            %% exclude injection site
%             injectsumfile=[savedir,'/',animalid,'_regioninject_',num2str(tracerinfo(k,2)),'.csv'];
            injectvolfile=[savedir,'/',animalid,'_mapinject.mat'];
            injsumvol=load(injectvolfile);
            injvol=injsumvol.mapvol;
            noninjmap=injvol==0;
            neuronvol_noinj=neuronvol.*noninjmap;
            %% summarize each animal into a region matrix
            [neuroncount{k}(:,1),neuroncount{k}(:,2),~]=region_density_list(neuronvol_noinj,annovol);
            % normalize into percentage
            neuroncount{k}(:,2)=neuroncount{k}(:,2)/sum(neuroncount{k}(:,2));
        end
        %% consolidate across animals
        regionids=[];
        for k=1:size(tracerinfo,1)
            regionids=[regionids;neuroncount{k}(:,1)];
        end
        regionids=unique(nonzeros(regionids));
        regionneuron=zeros(length(regionids),size(tracerinfo,1));
        for j=1:length(regionids)
            regionid=regionids(j);
            for k=1:size(tracerinfo,1)
                cellind=find(neuroncount{k}(:,1)==regionid);
                if ~isempty(cellind)
                    regionneuron(j,k)=neuroncount{k}(cellind,2);
                end
            end
        end
        %% assign into label bar
        %     load([targetdir,'/toplevelindices'],'regionlabel')
        regionsummary=topregionlabel;
        for k=1:length(topregionlabel)
            regionsummary{k,3}=[regionsummary{k,3},zeros(size(regionsummary{k,3},1),size(tracerinfo,1))];
        end
        for j=1:length(regionids)
            regionid=regionids(j);
            a=0;
            ind=[];
            while isempty(ind)
                a=a+1;
                if a<=size(topregionlabel,1)
                    ind=find(topregionlabel{a,3}(:,1)==regionid);
                else
                    break
                end
            end
            if ~isempty(ind)
                regionsummary{a,3}(ind,:)=[topregionlabel{a,3}(ind,1),regionneuron(j,:)];
            end
        end
        neuronsorted=cell2mat(regionsummary(:,3));
        %% save
        if r==1 && t==1
            tracer='antero';
            M1antero=neuronsorted;
            save([outputdir,'/',injinfofile],'M1antero','-append')
        elseif r==1 && t==2
            tracer='retro';
            M1retro=neuronsorted;
            save([outputdir,'/',injinfofile],'M1retro','-append')
        elseif r==2 && t==1
            tracer='antero';
            M2antero=neuronsorted;
            save([outputdir,'/',injinfofile],'M2antero','-append')
        elseif r==2 && t==2
            tracer='retro';
            M2retro=neuronsorted;
            save([outputdir,'/',injinfofile],'M2retro','-append')
        end
        %% visualization
        if nargin>4
            if visfig==1
                
                figure, imagesc(neuronsorted(:,2:end))
                colormap hot
                caxis([0 .1])
                figfile=['M',num2str(r),tracer,'_',num2str(size(tracerinfo,1)),'cases'];
                saveas(gcf,[outputdir,'/',figfile,'.fig'])
                saveas(gcf,[outputdir,'/',figfile,'.eps'],'epsc')
                close
                figure, imagesc(mean(neuronsorted(:,2:end),2))
                colormap hot
                caxis([0 .1])
                figfile=['M',num2str(r),tracer,'_',num2str(size(tracerinfo,1)),'mean'];
                saveas(gcf,[outputdir,'/',figfile,'.fig'])
                saveas(gcf,[outputdir,'/',figfile,'.eps'],'epsc')
                close
                % top level label bar
                A=[];k=0;
                for a=1:size(topregionlabel,1)
                    k=k+1;
                    A=[A,ones(1,length(topregionlabel{a,3}))*k];
                end
                figure, imagesc(A')
                saveas(gcf,[outputdir,'/toplabelbar.eps'],'epsc')
                close
            end
        end
    end
end