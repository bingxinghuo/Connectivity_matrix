%% establish correspondence between individual fluorescent section and annotation images
%% note that there are 40 anterior padding and 15 posterior padding for all annotation.img files
function [annoimgs,seclist]=loadannoimg(annoimgfile,seclistfile,flips)
% load annotation
annostack=load_nii(annoimgfile);
annoimgs=annostack.img;
annoimgs(annoimgs>=10000)=annoimgs(annoimgs>=10000)-10000; % adjust LR hemisphere difference
if ~isempty(flips)
    for i=1:length(flips)
        annoimgs=flip(annoimgs,flips(i));
    end
end
% load correspondence
if ~exist(seclistfile,'file')
    disp('Please establish section correspondence by running F_REG_secnum.py! ')
    %%%% run F_REG_secnum.py in shell
    % ANIMALID=822
    % python ~/Documents/GITHUB/injection_detection/F_REG_secnum.py M$ANIMALID F ~/CSHLservers/mitragpu3/marmosetRIKEN/NZ/m$ANIMALID/m$ANIMALID"F"/JP2-REG/m$ANIMALID"F-STIF" ~/"Dropbox (Marmoset)"/BingxingHuo/"Marmoset Brain Architecture"/"Paul Martin"/M$ANIMALID 91 190
    %%%%
end
fid=fopen(seclistfile); % output from F_REG_secnum.py
seclist=textscan(fid,'%q %u','Delimiter',',');
fclose(fid);