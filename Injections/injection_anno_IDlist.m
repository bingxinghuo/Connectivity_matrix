filename='m1228_mapinjectID_2.tiff';
[filepath,filename0,fileext]=fileparts(filename);
outputfile=[filepath,filename,'.csv'];
imginfo=imfinfo(filename);
injid=imread(filename,1);
for i=2:length(imginfo)
injid(:,:,i)=imread(filename,i);
end
A=nonzeros(unique(injid));
injarea=zeros(length(A),1);
for a=1:length(A)
injarea(a)=sum(sum(sum(injid==A(a))));
end
[~,sorti]=sort(injarea,'descend');
IDsorted=A(sorti);
fracsorted=injarea(sorti)./sum(injarea);
volsorted=injarea(sorti)*(.08)^3;
fid=fopen(outputfile,'w');
for i=1:length(A)
    fprintf(fid,'%d,%f,%f\n',A(sorti(i)),fracsorted(i),volsorted(i));
end
fclose(fid);