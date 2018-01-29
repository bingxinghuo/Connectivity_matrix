%% xregFluoroToNissl.m
% This function performs rigid transformation from Nissl to its neighboring fluorescent image
% Inputs:
%   - nissljp2: a string containing the jp2 file of the Nissl section
%   - fluorojp2: a string containing the jp2 file of the Nissl section
function xregFluoroToNissl(nissljp2,fluorojp2,transformtxt)
if ~exist(transformtxt,'file')
    %% 1. Read in images
    % 1.1 Nissl
    nissltif=[nissljp2(1:end-4),'_64down.tif'];
    if ~exist(nissltif,'file')
        % load
        nisslimg=imread(nissljp2,'jp2');
        % downsample
        for i=1:3
            nisslsmall(:,:,i)=downsample_max(nisslimg(:,:,i),64);
        end
        % combine to grayscale
        nisslsmallgray=uint8(mean(nisslsmall,3));
        % save
        imwrite(nisslsmallgray,nissltif,'tif','compression','lzw')
    end
    % 1.2 Fluorescent image
    fluorotif=[fluorojp2(1:end-4),'_64down.tif'];
    if ~exist(fluorotif,'file')
        % load
        fluoroimg=imread(fluorojp2,'jp2');
        % downsample
        for i=1:3
            fluorosmall(:,:,i)=jp22tif_downsample(fluoroimg(:,:,i),64);
        end
        % combine to grayscale
        fluorosmallgray=uint8(mean(fluorosmall,3));
        % save
        imwrite(fluorosmallgray,fluorotif,'tif','compression','lzw')
    end
    %% 2. Python code to generate the transformation matrix
    % add python search directory, if necessary
    pydirectory='/home/bingxing/scripts/Connectivity_matrix/xregist/';
    P = py.sys.path;
    if count(P,pydirectory) == 0
        insert(P,int32(0),pydirectory);
    end
    nissldeformed=[nissljp2(1:end-4),'_64down_deformed.tif'];
    % python rigidFluoroToNissl.py F50/F50down.tif F50/N50down.tif F50/N50deformed.tif F50/rigidtransform.txt
    py.rigidFluoroToNissl(nissltif,fluorotif,nissldeformed,transformtxt)
end
%% 3. Apply the transformation matrix to original Nissl image
nisslfinaltif=[nissljp2(1:end-4),'_deformed.tif'];
% python applyxregFluoroToNissl.py <template.jp2/.tif> <target.jp2/.tif> <transform.txt> <output.tif>
% output image is saved in tif format
py.applyxregFluoroToNissl(nissljp2,fluorojp2,transformtxt,nisslfinaltif)
%% 4. Compress the image to JP2
nisslfinaljp2=[nisslfinaltif(1:end-4),'.jp2'];
status=system(['/usr/local/Kakadu/v7_7-01668N/bin/Linux-x86-64-gcc/kdu_compress -i ',...
    nisslfinaltif,' -o ',nisslfinaljp2,' -num_threads 8 -rate 1.0 Creversible=yes ',...
    'Sprecision=16 Ssigned=no -full -precise Clevels=7 Clayers=8 Qstep=0.00001 Cblk=\{64,64\} ',...
    'Corder=RPCL Cuse_sop=yes ORGgen_plt=yes ORGtparts=R -quiet']);