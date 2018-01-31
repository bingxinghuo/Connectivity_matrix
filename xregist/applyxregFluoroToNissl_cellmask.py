import numpy as np
import os, math, sys
import SimpleITK as sitk
#import cv2

sys.path.insert(0,"/home/bingxing/scripts/Connectivity_matrix/xregist")
#sys.path.insert(0,"/Users/bingxinghuo/Documents/GITHUB/Connectivity_matrix/xregist")
import ndreg2D

def main():
    template = sitk.ReadImage(sys.argv[1], sitk.sitkFloat32)# full resolution grayscale image to be deformed
    width=sys.argv[2]
    height=sys.argv[3]
#    target=cv2.imread(sys.argv[2]) # full resolution target image
#    target=sitk.GetImageFromArray(target,isVector=True)
#    transformfile = open(sys.argv[3])
    transformfile = open(sys.argv[4])
    # read the transformation matrix
    with transformfile as f:
        euler2d=f.read().splitlines()

    euler2d=map(float,euler2d)

# apply transformation
#    outImg = ndreg2D.imgApplyAffine2D(template,euler2d,size=target.GetSize())
    outImg = ndreg2D.imgApplyAffine2D(template,euler2d,size=[width,height])

    sitk.WriteImage(outImg,sys.argv[4])
    transformfile.close()
    return

if __name__=="__main__":
    main()
