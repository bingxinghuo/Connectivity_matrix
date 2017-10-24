import numpy as np
import os, math, sys
import SimpleITK as sitk
import ndreg2D
from scipy.misc import imsave

def main():
    template=sitk.ReadImage(sys.argv[1], sitk.sitkFloat32) # full resolution image to be deformed
    target=sitk.ReadImage(sys.argv[2]) # full resolution target image
    transformfile = open(sys.argv[3])
    # read the transformation matrix
    with transformfile as f:
        euler2d=f.read().splitlines()
        euler2d=map(float,euler2d)

    outImg = ndreg2D.imgApplyAffine2D(template,euler2d,size=target.GetSize())
    outImgM=sitk.GetArrayFromImage(outImg)
    imsave(sys.argv[3],outImgM)
    transformfile.close()
    return

if __name__=="__main__":
    main()
