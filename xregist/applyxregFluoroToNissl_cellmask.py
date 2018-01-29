import numpy as np
import os, math, sys
import SimpleITK as sitk
import cv2

sys.path.insert(0,"/home/bingxing/scripts/Connectivity_matrix/xregist")
import ndreg2D

def main():
    template=cv2.imread(sys.argv[1]) # full resolution image to be deformed
    target=cv2.imread(sys.argv[2]) # full resolution target image
    target=sitk.GetImageFromArray(target,isVector=True)
    transformfile = open(sys.argv[3])
    # read the transformation matrix
    with transformfile as f:
        euler2d=f.read().splitlines()

    euler2d=map(float,euler2d)

# only 1 channel
    outImgM=[None]
    template2D=template
   # template2D=sitk.GetImageFromArray(template2D,isVector=True)
    outImg = ndreg2D.imgApplyAffine2D(template2D,euler2d,size=target.GetSize())
#    outImgM=sitk.GetArrayFromImage(outImg)

# merge the RGB channels
    #outImg=cv2.merge((outImgM[0],outImgM[1],outImgM[2]))
    cv2.imwrite(sys.argv[4],outImg)
    transformfile.close()
    return

if __name__=="__main__":
    main()
