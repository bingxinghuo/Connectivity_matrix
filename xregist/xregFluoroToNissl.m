%% xregFluoroToNissl.m
% This function performs rigid transformation from Nissl to its neighboring fluorescent image
% Inputs:
%   - nissljp2: a string containing the jp2 file of the Nissl section
%   - fluorojp2: a string containing the jp2 file of the Nissl section
function xregFluoroToNissl(nissljp2,fluorojp2,animalid,transformtxt,celljp2,M)
if ~exist(transformtxt,'file')
    %% 1. Read in small tifs
    % 1.1 Nissl
    updirind=strfind(nissljp2,'/');
    tifdir=[nissljp2(1:updirind(end-1)),upper(animalid),'N-STIF/'];
    if exist(tifdir,'dir')
        nissltif=[tifdir,nissljp2(updirind(end)+1:end-4),'.tif'];
        if ~exist(nissltif,'file')
            error('Missing Nissl downsampled tiff file!')
            %         % load
            %         nisslimg=imread(nissljp2,'jp2');
            %         [nisslheight,nisslwidth,~]=size(nisslimg);
            %         % downsample
            %         for i=1:3
            %             nisslsmall(:,:,i)=downsample_mean(nisslimg(:,:,i),M);
            %         end
            %         % combine to grayscale
            %         nisslsmallgray=uint8(mean(nisslsmall,3));
            %         % save
            %         imwrite(nisslsmallgray,nissltif,'tif','compression','lzw')
            %     else
        end
        imgsize=imfinfo(nissljp2);
        nisslwidth=imgsize.Width;
        nisslheight=imgsize.Height;
    end
    % 1.2 Fluorescent image
    updirind=strfind(fluorojp2,'/');
    animalseries=[fluorojp2(updirind(end-2)+1:updirind(end-1)-1)];
    tifdir=[fluorojp2(1:updirind(end-1)),upper(animalid),'F-STIF/'];
    if exist(tifdir,'dir')
        fluorotif=[tifdir,fluorojp2(updirind(end)+1:end-4),'.tif'];
        if ~exist(fluorotif,'file')
            error('Missing fluorescent downsampled tiff file!')
            %     if ~exist(fluorotif,'file')
            %         % load
            %         fluoroimg=imread(fluorojp2,'jp2');
            %         % downsample
            %         for i=1:3
            %             fluorosmall(:,:,i)=downsample_mean(fluoroimg(:,:,i),M);
            %         end
            %         % combine to grayscale
            %         fluorosmallgray=uint8(mean(fluorosmall,3));
            %         % save
            %         imwrite(fluorosmallgray,fluorotif,'tif','compression','lzw')
            %     end
        end
        xregFdir=['../xregF/'];
        if ~exist(xregFdir,'dir')
            mkdir(xregFdir)
        end
        fluorotif_deformed=[xregFdir,fluorojp2(updirind(end)+1:end-4),'.tif'];
    end
    %% 2. Python code to generate the transformation matrix
    status=system(['python ~/scripts/Connectivity_matrix/xregist/rigidFluoroToNissl_cellmask.py ',...
        nissltif,' ',fluorotif,' ',fluorotif_deformed,' ',transformtxt]);    
end
%% 3. Apply the transformation matrix to fluorescent cell image
celljp2_deformed=[celljp2(1:end-4),'_deformed.jp2'];
status=system(['python ~/scripts/Connectivity_matrix/xregist/applyxregFluoroToNissl_cellmask.py ',...
    celljp2,' ',transformtxt,' ',M,' ',num2str(nisslwidth),' ',num2str(nisslheight),' ',celljp2_deformed]);
% %% 4. Compress the image to JP2
% nisslfinaljp2=[cellfinaltif(1:end-4),'.jp2'];
% status=system(['/usr/local/Kakadu/v7_7-01668N/bin/Linux-x86-64-gcc/kdu_compress -i ',...
%     cellfinaltif,' -o ',nisslfinaljp2,' -num_threads 8 -rate 1.0 Creversible=yes ',...
%     'Sprecision=16 Ssigned=no -full -precise Clevels=7 Clayers=8 Qstep=0.00001 Cblk=\{64,64\} ',...
%     'Corder=RPCL Cuse_sop=yes ORGgen_plt=yes ORGtparts=R -quiet']);