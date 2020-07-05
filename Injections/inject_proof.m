% assist with injection proofreading by finding the largest object
function bw2=inject_proof(stackvol,blursd,thresh,N)
if nargin<2
    blursd=1;
end
if nargin<3
    thresh=0;
end
if nargin<4
    N=1;
end
bw=imgaussfilt3(stackvol,blursd);
bw1=findbigobjects(bw>thresh,N);
bw2=stackvol.*cast(bw1,'like',stackvol);