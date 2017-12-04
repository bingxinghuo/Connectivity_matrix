% Inputs:
%   - layerlist: a cell structure containing all brain regions in each layer.
%   Each cell contains 2 columns, column 1 shows the region id, column 2
%   shows the index of the parent region in the previous layer. The 9 rows
%   show the 9 top layer structures. This is an output of brainlayers.m
%   - l0: the layer that contains the region of interest. All searches go
%   downsream
%   - topind: the index of the region of interest in l0.
%   - toplayer: the top layer of structure, shows within which row to search.
% Output:
%   - leafid: a column of region id's as the lowest level leaf for the
%   region of interest.
function leafid=extractleaf_marmo(layerlist,l0,topind,toplayer)
leafid=[];
for l=l0+1:length(layerlist(1,:)) % start search from the next layer
    cortind1=[];
    for i=1:length(topind)
        cortind1=[cortind1;find(layerlist{toplayer,l}(:,2)==topind(i))];  
    end
    leafid=[leafid;layerlist{1,l}(cortind1,1)];
    topind=cortind1;
end