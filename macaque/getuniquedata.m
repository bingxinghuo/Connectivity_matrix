function datauni=getuniquedata(datastruct,N)
if isstruct(datastruct.data)
    datafield=getfield(datastruct,'data');
    fnames=fieldnames(datafield);
    dataall=cell(length(fnames),1);
    for i=1:length(fnames)
        datatemp=getfield(datafield,fnames{i});
        dataall{i}=datatemp{N}; % injection id
    end
else
    for i=1:length(datastruct.data)
        dataall{i}=datastruct.data{i}{N};
    end
end
dataall1=cellfun(@str2num,dataall);
datauni=unique(dataall1);
size(datauni) 