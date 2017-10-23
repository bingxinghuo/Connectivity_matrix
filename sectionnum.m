singles{1}='M819-N85--_3_0255.jp2';
singles{2}='M819-N350--_3_1050.jp2';
for i=1:2
files=strfind(filelist,singles{i}); % find all the files
singlesind(i)=find(~cellfun(@isempty,files));
end
Lf=length(filelist);
for f=1:Lf
    fileid=filelist{f};
    ii=str2num(fileid(end-9));
if f<singlesind(1)
    ColumnNumber = 3-ii; %AL- temp modify for section close issue - was 3 ^
       PredictedSectionNumber = 2;
       PredictedSectionNumber = (slideInfo.Number-1)*2+ColumnNumber;
   end