import numpy as np
import os, math, sys
import SimpleITK as sitk
import cv2

sys.path.insert(0,"/home/bingxing/scripts/Connectivity_matrix/xregist")
import ndreg2D

def main():
    template=cv2.imread(sys.argv[1],0) # full resolution grayscale image to be deformed
    target=cv2.imread(sys.argv[2]) # full resolution target image
    target=sitk.GetImageFromArray(target,isVector=True)
    transformfile = open(sys.argv[3])
    # read the transformation matrix
    with transformfile as f:
        euler2d=f.read().splitlines()

    euler2d=map(float,euler2d)

# apply transformation
    template2D=sitk.GetImageFromArray(template,isVector=True)
    outImg = ndreg2D.imgApplyAffine2D(template2D,euler2d,size=target.GetSize())
    outImg=sitk.GetArrayFromImage(outImg)

    cv2.imwrite(sys.argv[4],outImg)
    transformfile.close()
    return

if __name__=="__main__":
    main()
