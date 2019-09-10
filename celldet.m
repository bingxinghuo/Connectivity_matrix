function centroids=celldet(fileid,color,maskfile,bgimgmed0,bitinfo)
sizepar=[20,5000];
eccpar=[.99,.95];
sigma=[50,1];
bwimg=signaldet(fileid,color,maskfile,bgimgmed0,bitinfo);
if ~isempty(bwimg)
    %% 2. cell segmentation
    % 2.1 separate connected cells and single cells
    [bwimg_patch,gradimg,localmax]=cellpatch(bwimg,sigma);
    % 2.2 Separate individual cells in the connected patches
    if ~isempty(bwimg_patch{2}) % there exist connected cells
        bwimg_new=eccentricity(bwimg_patch{2},eccpar(1)); % filter shape
        bwimg_new=cellsize(bwimg_new,sizepar); % filter size
        bwimg_new=cellsep(bwimg_new,gradimg,localmax);
    end
    % 2.3 combine all individual cells
    bwimg_new=bwimg_new+bwimg_patch{1}; % all individual cells now
    clear bwimg_patch
    %% 3. feature filters
    %     bwimg_filt=cellcolor(bwimg_new,fluoroimg); % check the color of cells
    bwimg_filt=cellsize(bwimg_new,sizepar); % filter for cell sizes
    bwimg_filt=eccentricity(bwimg_filt,eccpar(2)); % the cell need to be more round than linear
    % L=cellSNR(L,imgbit,bitinfo); % filter for SNR
    clear bwimg_new
    %% 4. detect centroids
    cc=bwconncomp(bwimg_filt);
    rprops = regionprops(cc,'centroid');
    centroids=reshape([rprops.Centroid],2,[])';
else
    centroids=[];
end