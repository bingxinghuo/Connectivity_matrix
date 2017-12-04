%% generate second Xform file
orig_target_STS = transformOriginalTargetImage(targetfilename,transformdirectoryname,nepochs);
orig_target_STS.fileprefix = [dataoutputdirectoryname '/' patientnumber '_orig_target_STS'];
avw_img_write(orig_target_STS, orig_target_STS.fileprefix);

missingsliceind = [];
for i = 1:size(orig_target_STS.img,2)
    if size(unique(orig_target_STS.img(:,i,:)),1) < 3
        missingsliceind = [missingsliceind i];
    end
end
fid = fopen([transformdirectoryname patientnumber '_XForm.txt'],'w');
fid2 = fopen([transformdirectoryname patientnumber '_XForm_matrix.txt'],'w');
a_old(missingsliceind) = [];
b_old(missingsliceind) = [];
theta_old(missingsliceind) = [];
for i = 1:length(a_old)
    R = [cos(theta_old(i)) -sin(theta_old(i)) a_old(i);sin(theta_old(i)) cos(theta_old(i)) b_old(i); 0 0 1];
    fprintf(fid, '%f,%f,1,1,%d,%d,%f,%f,%f,%f,%f,%d,%d,%d\n',0,0,orig_target_STS.hdr.dime.dim(4),orig_target_STS.hdr.dime.dim(2),theta_old(i),double(orig_target_STS.hdr.dime.dim(4))/2,double(orig_target_STS.hdr.dime.dim(2))/2,b_old(i),a_old(i), 0,0,0);
    fprintf(fid2,'%f,%f,%f,%f,%f,%f,%f,%f,\n', R(1,1), R(1,2), R(2,1), R(2,2), R(1,3), R(2,3), double(orig_target_STS.hdr.dime.dim(4))/2*double(orig_target_STS.hdr.dime.pixdim(4)),double(orig_target_STS.hdr.dime.dim(2))/2*double(orig_target_STS.hdr.dime.pixdim(2)));
end
fclose(fid);
fclose(fid2);
%% rigidly register the atlas to the target
targetfilename = [orig_target_STS.fileprefix '.img'];
system(['python rigidAlignMarmosetAtlas.py ' atlasfilename ' ' targetfilename ' ' annofilename ' ' atlasmaskfilename ' ' dataoutputdirectoryname patientnumber '_affine.img ' dataoutputdirectoryname patientnumber '_annotation_affine.img ' dataoutputdirectoryname patientnumber '_atlasmask_affine.img ' dataoutputdirectoryname patientnumber '_globalaffinetrans.txt']);


%% do lddmm from atlas to target
% mask the target
system(['python maskMarmosetTarget.py ' orig_target_STS.fileprefix '.img ' dataoutputdirectoryname patientnumber '_targetmask.img ' dataoutputdirectoryname patientnumber '_targetmasked.img']);

% maybe do histogram matching
localhist = False;
if localhist == True
    %system("matlab -nodesktop -singleCompThread -nojvm -nodisplay -r \"histmatch_daniel(\'/cis/home/leebc/Projects/Mouse_Histology/data/registration/" + patientnumber + "/" + patientnumber + "_targetmasked.img\', \'/cis/home/leebc/Projects/Mouse_Histology/data/registration/" + patientnumber + "/" + patientnumber + "_affine.img\',false);exit\"")
else
    system(['python histogramMatchingMarmoset.py ' dataoutputdirectoryname patientnumber '_targetmasked.img ' dataoutputdirectoryname patientnumber '_affine.img ' dataoutputdirectoryname patientnumber '_affine_lhm.img']);
end

% do smoothing
lhmtarget = avw_img_read([orig_target_STS.fileprefix '.img']);
lhmtarget.img = imgaussfilt3(lhmtarget.img,0.75);
lhmtarget.fileprefix = [dataoutputdirectoryname patientnumber '_targetsmoothed'];
avw_img_write(lhmtarget, lhmtarget.fileprefix);

lhmatlas = avw_img_read([dataoutputdirectoryname patientnumber '_affine_lhm.img']);
lhmatlas.img = imgaussfilt3(lhmatlas.img,0.75);
lhmatlas.fileprefix = [dataoutputdirectoryname patientnumber '_affine_lhmsmooth'];
avw_img_write(lhmatlas,lhmatlas.fileprefix);

% do lddmm
system(['./mm_lddmm2n_ver03_evensmallersig.pl 2 ' lhmatlas.fileprefix '.img ' lhmtarget.fileprefix '.img 0.4 ' atlasmaskfilename ' ' dataoutputdirectoryname patientnumber '_targetmask.img 0.075 ' dataoutputdirectoryname patientnumber '_lddmm 3 0.05 10 0.02 10 0.01 10 1 1 1.0']);

% apply transform to annotation
system(['./IMG_apply_lddmm_tform1 ' dataoutputdirectoryname patientnumber '_annotation_affine.img ' dataoutputdirectoryname patientnumber '_lddmm/Hmap000.vtk ' dataoutputdirectoryname patientnumber '_annotation.img 2']);

% post processing transform files
sysetm(['python convertVTK.py ' dataoutputdirectoryname patientnumber '_lddmm/Hmap000.vtk ' dataoutputdirectoryname patientnumber '_lddmm/Kimap000.vtk ' transformdirectoryname 'field_forward.vtk ' transformdirectoryname 'field_reverse.vtk']);
