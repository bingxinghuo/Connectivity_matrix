 if(slideInfo.Number < f_split)
       ColumnNumber = 3-ii; %AL- temp modify for section close issue - was 3 ^
       PredictedSectionNumber = 2;
       PredictedSectionNumber = (slideInfo.Number-1)*2+ColumnNumber;
   end
   if(slideInfo.Number >= f_split) && (slideInfo.Number <= s_split)
       ColumnNumber = 2-ii;
       PredictedSectionNumber = 1;
       PredictedSectionNumber = (f_split - 2)*2 + 2 + (slideInfo.Number - f_split)+ColumnNumber;
   end

   if(slideInfo.Number > s_split)
       ColumnNumber = 3-ii;
       PredictedSectionNumber = 2;
       PredictedSectionNumber = ((f_split-2)*2 + 2) + ((s_split - f_split)+1) + ((slideInfo.Number - s_split + 1)*2 + ColumnNumber);
   end