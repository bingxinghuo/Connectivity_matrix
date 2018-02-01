%% xregFluoroToNissl.m
% This function performs rigid transformation from Nissl to its neighboring fluorescent image
% Inputs:
%   - nissljp2: a string containing the jp2 file of the Nissl section
%   - fluorojp2: a string containing the jp2 file of the Nissl section
function xregFluoroToNissl(nissljp2,fluorojp2,transformtxt,celljp2,M)
if ~exist(transformtxt,'file')
    %% 1. Read in images
    % 1.1 Nissl
    nissltif=[nissljp2(1:end-4),'_down.tif'];
    if ~exist(nissltif,'file')
        % load
        nisslimg=imread(nissljp2,'jp2');
        % downsample
        for i=1:3
            nisslsmall(:,:,i)=downsample_max(nisslimg(:,:,i),M);
        end
        % combine to grayscale
        nisslsmallgray=uint8(mean(nisslsmall,3));
        % save
        imwrite(nisslsmallgray,nissltif,'tif','compression','lzw')
    end
    % 1.2 Fluorescent image
    fluorotif=[fluorojp2(1:end-4),'_down.tif'];
    if ~exist(fluorotif,'file')
        % load
        fluoroimg=imread(fluorojp2,'jp2');
        % downsample
        for i=1:3
            fluorosmall(:,:,i)=downsample_max(fluoroimg(:,:,i),M);
        end
        % combine to grayscale
        fluorosmallgray=uint8(mean(fluorosmall,3));
        % save
        imwrite(fluorosmallgray,fluorotif,'tif','compression','lzw')
    end
    %% 2. Python code to generate the transformation matrix
    status=system(['python ~/scripts/Connectivity_matrix/xregist/rigidFluoroToNissl_cellmask.py ',...
        nissltif,' ',fluorotif,' ',fluorotif_deformed,' ',num2str(M),' ',transformtxt]);
    
end
%% 3. Apply the transformation matrix to fluorescent cell image
celljp2_deformed=[celljp2(1:end-4),'_deformed.jp2'];
imgsize=imfinfo(nissljp2);
imgwidth=imgsize.Width;
imgheight=imgsize.Height;
status=system(['python ~/scripts/Connectivity_matrix/xregist/applyxregFluoroToNissl_cellmask.py ',...
    nissljp2,' ',celljp2,' ',transformtxt,' ',celljp2_deformed]);
% %% 4. Compress the image to JP2
% nisslfinaljp2=[cellfinaltif(1:end-4),'.jp2'];
% status=system(['/usr/local/Kakadu/v7_7-01668N/bin/Linux-x86-64-gcc/kdu_compress -i ',...
%     cellfinaltif,' -o ',nisslfinaljp2,' -num_threads 8 -rate 1.0 Creversible=yes ',...
%     'Sprecision=16 Ssigned=no -full -precise Clevels=7 Clayers=8 Qstep=0.00001 Cblk=\{64,64\} ',...
%     'Corder=RPCL Cuse_sop=yes ORGgen_plt=yes ORGtparts=R -quiet']);