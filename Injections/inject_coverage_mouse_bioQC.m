annoimgfile='~//Dropbox (Mitra Lab)/Data and Analysis/Mouse/MouseBrainAtlases/AllenMouseBrainAtlas/Standardized/Annotation_for_Nissl/annotation_mapped_25_bregma.vtk';
[xA,yA,zA,atlas,title_,names,spacing] = read_vtk_image(annoimgfile);
atlas=permute(atlas,[2,1,3]);
% mouse
% origin=[35,228,320]; % inferior-left-anterior
origin=[20,228,320]; % inferior-left-anterior. Adjusted bregma to take into in vivo & skull
voxsize=25;
%%
% clear InjectionplanrAAV
% uiopen('/Users/bingxinghuo/Dropbox (Mitra Lab)/Data and Analysis/Mouse/Joint_Analysis/Injection/Injectionplan_rAAV.xlsx',1)
% allinj=table2cell(InjectionplanrAAV);
allinj=table2cell(locationPMDAAV2);
L=size(allinj,1);
% Column 1 contains initial injection ID
firstinj=zeros(L,1);
for i=1:L
    firstid=allinj{i,1};
    firstid=regexp(firstid,'\d*','Match');
    if ~isempty(firstid)
        firstid=str2double(firstid);
    else
        firstid=0;
    end
    firstinj(i)=firstid;
end
allinj1=firstinj;
% Column 2 contains injection repetitions
injreps=cell(L,1);
injcounts=zeros(L,1);
for i=1:L
    repids=allinj{i,2};
    repids=regexp(repids,'\d*','Match');
    if ~isempty(repids)
        repids=str2double(repids);
        injcounts(i)=length(repids);
    else
        injcounts(i)=0;
    end
    injreps{i}=repids;
end
allinj(:,2)=injreps;
allinj1(:,2)=injcounts;
% Columns 3-5 contains injection coordinates, Column 6 contains flag of
% whether it has been injected
allinj1(:,3:6)=cell2mat(allinj(:,3:6));
%% convert injection coordinates into atlas coordinates
% allinjcoord=cell2mat(allinj(:,3:5)); % InjectionplanrAAV
allinjcoord=cell2mat(allinj(:,4:6)); % locationPMDAAV2
injinfoall=cell(L,2);
for i=1:L
%     injinfoall{i}.id=strcat(allinj(i,1),allinj(i,2));
    injinfoall{i}.id=strcat(allinj(i,1));
    injcent(1)=origin(1)+allinjcoord(i,3)*1000/voxsize; % DV, ventral is positive
    injcent(2)=origin(2)-allinjcoord(i,1)*1000/voxsize; % ML, left is positive
    injcent(3)=origin(3)+allinjcoord(i,2)*1000/voxsize; % AP, anterior is positive
    injinfoall{i}.com=round(injcent);
        % adjust injection DV counting from dorsal surface
    dvstart=find(squeeze(atlas(:,injinfoall{i}.com(2),injinfoall{i}.com(3))));
    if ~isempty(dvstart)
    injcent(1)=dvstart(1)+allinjcoord(i,3)*1000/voxsize; % DV, ventral is positive
    injinfoall{i}.com=round(injcent);
    injinfoall{i,2}=atlas(max(1,injinfoall{i}.com(1)),injinfoall{i}.com(2),injinfoall{i}.com(3));
end
%% save into separate volumes
% tracers='rAAV';
se=strel('sphere',ceil(150/voxsize));
types=unique(allinj1(:,6))
for k=1:length(types)
    typeind=find(allinj1(:,6)==types(k));
    centvol=zeros(size(atlas));
    for i=typeind'
        if ~isempty(injinfoall{i})
            brainid=allinj1(i,1);
            if isempty(brainid)
                brainid=str2double(injinfoall{i}.id{1}(2));
            end
            try
                if atlas(injinfoall{i}.com(1),injinfoall{i}.com(2),injinfoall{i}.com(3))>0
                    centvol(injinfoall{i}.com(1),injinfoall{i}.com(2),injinfoall{i}.com(3))=brainid;
                end
            catch
                injinfoall{i}
            end
            try
                if atlas(max(1,injinfoall{i}.com(1)-500/voxsize),injinfoall{i}.com(2),injinfoall{i}.com(3))>0
                    centvol(max(1,injinfoall{i}.com(1)-500/voxsize),injinfoall{i}.com(2),injinfoall{i}.com(3))=brainid; % a second injection was placed at 500um shallower location
                end
            catch
                injinfoall{i}
            end
        end
    end
    centvol=imdilate(centvol,se);
    imwrite(uint16(centvol(:,:,1)),['inj_rAAV',num2str(types(k)),'_mouse.tif'],'writemode','overwrite','compression','packbit')
    for i=2:size(atlas,3)
        imwrite(uint16(centvol(:,:,i)),['inj_rAAV',num2str(types(k)),'_mouse.tif'],'writemode','append','compression','packbit')
    end
end
%%
injanno=cell2mat(injinfoall(:,2));
scid=childreninfo(mouselist,302,0);
scid=[scid;childreninfo(mouselist,294,0)];
scid=cell2mat(scid(:,4));
injsc=ismember(injanno(:,1),scid);
injsc=find(injsc,2);