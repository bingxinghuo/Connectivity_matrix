% 1. Nissl
% 1.1 load
img50N=imread('M820-N50--_3_0150.jp2','jp2');
% 1.2 downsample
for i=1:3
    img50Ndown(:,:,i)=jp22tif_downsample(img50N(:,:,i),64);
end
% 1.3 combine to grayscale
img50Ndownsum=uint8(mean(img50Ndown,3));
% 1.4 save
imwrite(img50Ndownsum,'N50down.tif','tif','compression','lzw','writemode','overwrite')
% 2. Fluorescent image
% 2.1 load
img50F=imread('M820-F50--_3_0150.jp2','jp2');
% 2.2 downsample
for i=1:3
    img50Fdown(:,:,i)=jp22tif_downsample(img50F(:,:,i),64);
end
% 1.3 combine to grayscale
img50Fdownsum=uint8(mean(img50Fdown,3));
% 1.4 save
imwrite(img50Fdownsum,'F50down.tif','tif','compression','lzw','writemode','overwrite')
%% 2. Python code to generate the transformation matrix
% python rigidFluoroToNissl.py F50/F50down.tif F50/N50down.tif F50/N50deformed.tif F50/rigidtransform.txt
%% 3. Apply the transformation matrix to original Nissl image
% python applyxregFluoroToNissl.py <template> <target> <transform.txt> <output>
% output image is saved in tif format
%% 4. Compress the image to JP2
% usr/local/Kakadu/v7_7-01668N/bin/Linux-x86-64-gcc/kdu_compress -i N50deformed.tif -o N50deformed.jp2 -num_threads 8 -rate 1.0 Creversible=yes Sprecision=16 Ssigned=no -full -precise Clevels=7 Clayers=8 Qstep=0.00001 Cblk=\{64,64\} Corder=RPCL Cuse_sop=yes ORGgen_plt=yes ORGtparts=R -quiet