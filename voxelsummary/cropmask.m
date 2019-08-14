function imgmask=cropmask(img,n)
if nargin==1
    n=2;
end
se=strel('disk',n);
maskthresh=graythresh(img);
imgmask=imbinarize(img,maskthresh);
imgmask=imerode(imgmask,se);