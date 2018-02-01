import numpy as np
import os, math, sys
import SimpleITK as sitk
import cv2

sys.path.insert(0,"/home/bingxing/scripts/Connectivity_matrix/xregist")
#sys.path.insert(0,"/Users/bingxinghuo/Documents/GITHUB/Connectivity_matrix/xregist")
import ndreg2D

def main():
    target=cv2.imread(sys.argv[1]) # full resolution target image
    target=sitk.GetImageFromArray(target,isVector=True)
    target.SetSpacing([1.0,1.0])
#    target.SetSpacing([0.00046,0.00046]*64)
    template=cv2.imread(sys.argv[2]) # full resolution image to be deformed
    template2D=sitk.GetImageFromArray(template,isVector=True)
    template2D.SetSpacing(target.GetSpacing())
    transformfile = open(sys.argv[3])
    # read the transformation matrix
    with transformfile as f:
        euler2d=f.read().splitlines()

    euler2d=map(float,euler2d)
    euler2d[4:6]=[x*64 for x in euler2d[4:6]]

# apply transformation
    outImg = ndreg2D.imgApplyAffine2D(template2D,euler2d,size=target.GetSize())
    outImg=sitk.GetArrayFromImage(outImg)
    cv2.imwrite(sys.argv[4],outImg)
#    sitk.WriteImage(outImg,sys.argv[4])
    transformfile.close()
    return

if __name__=="__main__":
    main()
