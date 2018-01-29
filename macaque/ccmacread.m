%% 1. Injection stats
% CoCoMac query: SELECT ?ID_injection" FROM ?LabelledSites_Descriptions"
% save the result as Injections_ID.json
cocoinj=loadjson('Injections_ID.json');
cocoinjn=getuniquedata(cocoinj,1);
% 3279 injections
%% 2.1 Labeled neurons information
% CoCoMac query: SELECT "ID_injection" FROM "LabelledSites_Descriptions"
% save the result as label_inj_ID.json
labelinj=loadjson('label_inj_ID.json');
labelinjn=getuniquedata(labelinj,1);
% 3044 total injections with labeled neuron properties
%% 2.2 Corresponding anterograde or retrograde information
%  CoCoMac query: SELECT "Terminal_vs_Soma" FROM "LabelledSites_Descriptions"
% save the result as label_termi_soma.json
injdir=loadjson('label_termi_soma.json');
for i=1:length(injdir.data)
    dirall{i}=injdir.data{i}{1};
end
for i=1:length(injdir.data)
    if ~isempty(dirall{i})
        dirante(i)=strcmpi(dirall{i},'T');
    end
end
sum(dirante)
% 1602 anterograde labels
for i=1:length(injdir.data)
    if ~isempty(dirall{i})
        dirretro(i)=strcmpi(dirall{i},'S');
    end
end
sum(dirretro)
% 2241 retrograde labels
% double check missed entries
for i=1:length(dirall)
dirs(i)=~strcmpi(dirall{i},'T')+~strcmpi(dirall{i},'S');
end
% there are 16 entries labeled '$' and 1 is empty
dirlabel=dirante+dirretro*2;
%% 2.3 combine injection and direction
for i=1:length(labelinj.data)
labelinjall{i}=labelinj.data{i}{1};
end
labelinjall=cellfun(@str2num,labelinjall);
labelcomp=[labelinjall',dirlabel'];
labeluni=unique(labelcomp,'rows');
length(labeluni)
% 3319 injections by double counting the bidirectional tracers
dirante1=labeluni(labeluni(:,2)==1,:); % 1429 unique anterograde injections
dirretro1=labeluni(labeluni(:,2)==2,:); % 1873 unique anterograde injections


