#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 22 15:12:37 2018

@author: bingxinghuo
"""

import SimpleITK as sitk
import numpy as np
import sys

patientnumber = sys.argv[1]
transformfile1matrix = sys.argv[2]
transformfile1 = sys.argv[3]
transformfile2matrix = sys.argv[4]
fileindstart = sys.argv[5]
fileindend = sys.argv[6]
outputdirectoryname = sys.argv[7]

# load the first transform file
#with open('M919_N_XForm_matrix_LGN1.txt') as f:
with open(transformfile1matrix) as f:
    content = f.readlines()
    
content = [x.strip() for x in content]

#with open('M919_N_XForm_LGN1.txt') as f:
with open(transformfile1) as f:
    content3 = f.readlines()

content3 = [x.strip() for x in content3]

mylist = [[0] * 12 for i in range(len(content))]
for i in range(len(content)):
    myelements = content[i].split(',')
    myelements3 = content3[i].split(',')
    mylist[i][1:9] = myelements[2:10]
    mylist[i][0] = int(myelements[0][-4:])
    mylist[i][9] = myelements[1]
    mylist[i][10] = myelements[0]
    mylist[i][11] = myelements3[8]

mylist_sorted = sorted(mylist,key=lambda x: x[0])
mylist_ind=[x[0] for x in mylist_sorted]
fileindstart=mylist_ind.index(int(fileindstart))
fileindend=mylist_ind.index(int(fileindend))

#with open('M919_XForm_matrix_LGN1.txt') as f:
with open(transformfile2matrix) as f:
    content4 = f.readlines()
    
content4 = [x.strip() for x in content4]
content4line = content4[0].split(',')

originalpixelsize = 0.01472 # assuming 32X downsampling from 0.46 µm/pixel
# z-axis spacing was 40 µm, as seen below

# loop over all images
registeredimagelist = [None]*int(mylist[-1:][0][0])
for i in range(fileindstart,fileindend+1):
    
    print(i)
    # generate first euler2d transform
    euler2dobj1 = sitk.Euler2DTransform()
    rotcenter1 = [float(mylist_sorted[i][7]),float(mylist_sorted[i][8])]
    euler2dobj1.SetCenter([x*originalpixelsize for x in rotcenter1]) # scale the center based on pixel size
    euler2dobj1.SetMatrix([float(x) for x in mylist_sorted[i][1:5]],tolerance=1e-5)
    mytheta = float(mylist_sorted[i][11])
    euler2dobj1.SetTranslation([float(x)*originalpixelsize for x in mylist_sorted[i][5:7]]) # scale translation on pixel size
    
    # generate second euler2d transform
    #euler2dobj2 = sitk.Euler2DTransform()
    #rotcenter2 = [float(mylist2[i][6]), float(mylist2[i][7])]
    #euler2dobj2.SetCenter([x*0.04 for x in rotcenter2]) # scale the center based on pixel size
    #euler2dobj2.SetMatrix([float(x) for x in mylist2[i][0:4]],tolerance=1e-5)
    #mytheta2 = np.arccos(float(mylist2[i][0]))
    #euler2dobj2.SetTranslation([float(x) for x in mylist2[i][4:6]])
    
    # generate last euler2d transform
    euler2dobj3 = sitk.Euler2DTransform()
    euler2dobj3.SetCenter((float(content4line[7]),float(content4line[6])))
    euler2dobj3.SetTranslation((float(content4line[5]),float(content4line[4])))
    euler2dobj3.SetMatrix((float(content4line[0]),-float(content4line[1]),-float(content4line[2]),float(content4line[3])),tolerance=1e-5)
    
    # combine transforms
    compositetransform = sitk.Transform(2,sitk.sitkComposite)
    compositetransform.AddTransform(euler2dobj1)
    compositetransform.AddTransform(euler2dobj3)
    #compositetransform.AddTransform(euler2dobj3)
    
    # load the corresponding tif image from stackalign data
    inSlice = sitk.ReadImage(mylist_sorted[i][9] + mylist_sorted[i][10] + '.tif',sitk.sitkFloat32)
    inSlice.SetSpacing((originalpixelsize, originalpixelsize))
    inSlice.SetOrigin((0,0))
    inSlice.SetDirection((1,0,0,1))
    
    # resample the image
    outSlice = sitk.Resample(inSlice, (750,563), compositetransform, sitk.sitkLinear, inSlice.GetOrigin(), inSlice.GetSpacing(), (1,0,0,1), 255.0)
#    registeredimagelist[int(mylist_sorted[i][0])-1] = outSlice
#    registeredimagelist[i-1] = outSlice
    sitk.WriteImage(outSlice,outputdirectoryname+'/'+mylist_sorted[i][10]+'_reg.tif')
    
#    
## join series on the registered image list
#testzeronp = np.ones((563,750))*255
#testzero = sitk.GetImageFromArray(testzeronp.astype('int32'))
##testzero = sitk.Image(750,563,0,sitk.sitkInt32)
#testzero.SetSpacing((0.01472,0.01472))
#noneind = [i for i, x in enumerate(registeredimagelist) if x == None]
#for i in noneind:
#    registeredimagelist[i] = sitk.Image(testzero)
#
#affine = sitk.AffineTransform(2)
#identityDirection = (1,0,0,1)
#registeredimagelist40 = [None]*len(registeredimagelist)
#for i in range(len(registeredimagelist)):
#    tempslice = sitk.Image(registeredimagelist[i])
#    tempslice.SetSpacing((0.01472,0.01472))
#    tempslice = sitk.SmoothingRecursiveGaussian(tempslice,0.01)
#    tempslice = sitk.Resample(tempslice, tuple([int(np.round(x/(0.04/0.01472))) for x in tempslice.GetSize()]), affine, sitk.sitkLinear, tempslice.GetOrigin(), (0.04,0.04), identityDirection, 0.0)
#    registeredimagelist40[i] = tempslice
#
#
#dimension = 3
#affine = sitk.AffineTransform(3)
#identityAffine = list(affine.GetParameters())
#identityDirection = list(affine.GetMatrix())
#zeroOrigin = [0]*dimension
#registeredImg = sitk.JoinSeries(registeredimagelist40)
#registeredImgNP = sitk.GetArrayFromImage(registeredImg)
#registeredImgNP = -1*(registeredImgNP-255)
#registeredImgNP = np.rot90(registeredImgNP,axes=(1,2))
#registeredImgNP = np.rot90(registeredImgNP)
#registeredImg = sitk.GetImageFromArray(registeredImgNP,sitk.sitkInt8)
#registeredImg.SetSpacing((0.04,0.04,0.04))
#registeredImg.SetDirection(identityDirection)
#registeredImg.SetOrigin(zeroOrigin)
#
#sitk.WriteImage(registeredImg, 'M919N_80_LGN1_firstalign.img')
