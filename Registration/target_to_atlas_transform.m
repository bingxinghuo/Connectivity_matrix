%% 1. Apply the section alignment transforms to the target image
% applySTSCompositeTransform_fluoro.py
% generate 'XXX_alignedtarget.img' file
%% 2. Apply the inverse diffeomorphism to the aligned target image
system(['./IMG_apply_lddmm_tform1 ' dataoutputdirectoryname patientnumber '_alignedtarget.img ' dataoutputdirectoryname patientnumber '_lddmm/Kimap000.vtk ' dataoutputdirectoryname patientnumber '_alignedtarget.img 2']);
%% 3. Apply an inverse of the global affine transform to that image to get to the atlas space
% system(['python rigidAlignMarmosetAtlas.py ' atlasfilename ' ' targetfilename ' ' annofilename ' ' atlasmaskfilename ' ' dataoutputdirectoryname patientnumber '_affine.img ' dataoutputdirectoryname patientnumber '_annotation_affine.img ' dataoutputdirectoryname patientnumber '_atlasmask_affine.img ' dataoutputdirectoryname patientnumber '_globalaffinetrans.txt']);
