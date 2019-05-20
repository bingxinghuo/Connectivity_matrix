###Injection Detection phase 1, before SNAKE

import cv2
import numpy as np
import glob
import matplotlib.pyplot as plt
import re
import os
from skimage.io import imread
from multiprocessing import Pool
from skimage.filters import threshold_otsu
from skimage.morphology import remove_small_objects
from skimage.segmentation import active_contour
from skimage.morphology import skeletonize
from skimage.morphology import convex_hull_image
from functools import partial
from time import gmtime, strftime
import matplotlib.image as mpimg
import pickle
import matplotlib.path as mplPath
import SimpleITK as sitk
import sys

def imread_fast(img_path):
    img_path_C= img_path.replace("&", "\&")
    base_C = os.path.basename(img_path_C)
    base_C = base_C[0:-4]
    base = os.path.basename(img_path)
    base = base[0:-4]
    os.system("kdu_expand -i "+img_path_C+" -o /sonas-hs/mitra/hpc/home/xli/Injection_Detect_Pipeline/temp/"+base_C+".tif -num_threads 1")
    img = imread('/sonas-hs/mitra/hpc/home/xli/Injection_Detect_Pipeline/temp/'+base+'.tif')
    os.system("rm /sonas-hs/mitra/hpc/home/xli/Injection_Detect_Pipeline/temp/"+base_C+'.tif')
    #if use skimge.io.imread, change RGB order to BGR
    img_BGR = np.copy(img)
    img_BGR[:,:,0] = img[:,:,2]
    img_BGR[:,:,2] = img[:,:,0]
    img_BGR = img_BGR - img_BGR.min()
    return img_BGR

def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)

def GetBlockList(x, y, overlap=10/2):
    x1=0
    y1=256
    blocklist=[]
    count = 0
    while (x1+256<x):
        x2=0
        y2=256
        while (x2+256<y):
            blocklist.append(np.asarray([x1,y1,x2,y2,count]))
            count = count + 1
            x2=y2-overlap
            y2=x2+256
        x1=y1-overlap
        y1=x1+256
    return blocklist

def Injection_Detection_thrd(img_path):
    img = imread_fast(img_path)
    print img_path
    #img = cv2.imread(img_path, -1)
    #img = img - img.min()
    basename = os.path.basename(img_path)
    single(img, basename)
    
    img_shape = img.shape
    img_grn = img[:,:,1]
    img_red = img[:,:,2]
    left_array_grn = img_grn[:, 0:img_shape[1]/2].ravel()
    left_array_red = img_red[:, 0:img_shape[1]/2].ravel()
    left_array_grn = left_array_grn[left_array_grn != 0]
    left_array_red = left_array_red[left_array_red != 0]
    thrd_grn = left_array_grn.mean()
    mask_grn = img[:,:,1] < thrd_grn * 5
    thrd_red = left_array_red.mean()
    mask_red = img[:,:,2] < thrd_red * 5
    
    img_grn[mask_grn] = 0
    img_grn = img_grn.ravel()
    img_grn = img_grn[img_grn != 0]
    otsu_res_grn = threshold_otsu(img_grn, nbins = 4095) * 1.1 #30% increase to deal with image without signal
    
    img_red[mask_red] = 0    
    img_red = img_red.ravel()
    img_red = img_red[img_red != 0]
    otsu_res_red = threshold_otsu(img_red, nbins = 4095) * 1.2
    
    os.system('mkdir '+save_path + '/Firstpass_otsu_G/')
    mask_g = img[:,:,1] > otsu_res_grn  #
    cv2.imwrite(save_path+'/Firstpass_otsu_G/'+basename, np.asarray(mask_g * 255, 'uint8'))
    
    os.system('mkdir '+save_path + '/Firstpass_otsu_R')
    mask_r = img[:,:,2] > otsu_res_red  #
    cv2.imwrite(save_path+'/Firstpass_otsu_R/'+basename, np.asarray(mask_r * 255, 'uint8'))
    
    
    os.system('mkdir '+save_path + '/Metadata_G/')
    file = open(save_path+'/Metadata_G/'+basename+'.txt', 'w')
    file.write("First Pass otsu thred\r\n")
    file.write(str(otsu_res_grn)+'\r\n')
    file.close()
    
    os.system('mkdir '+save_path + '/Metadata_R/')
    file = open(save_path+'/Metadata_R/'+basename+'.txt', 'w')
    file.write("First Pass otsu thred\r\n")
    file.write(str(otsu_res_red)+'\r\n')
    file.close()
    
    return

def Injection_Detection_Globalthrd(metadata_path):
    metadata_path_list = natural_sort(glob.glob(metadata_path + '*.txt'))
    otsu_list = []
    for ii in metadata_path_list:
        f = open(ii)
        lines = f.readlines()
        otsu_list.append(lines[1])
    otsu_list = np.asarray(otsu_list, 'float64')
    return np.min([otsu_list.mean(), np.median(otsu_list)])

def Injection_Detection_mask(GlobalThrd_G, GlobalThrd_R, img_path):
    img = imread_fast(img_path)
    print img_path
    #img = cv2.imread(img_path, -1)
    #img = img - img.min()
    
    basename = os.path.basename(img_path)
    mask_g = img[:,:,1] > GlobalThrd_G
    mask_g = remove_small_objects(mask_g, 100, connectivity=1)
    mask_g = np.asarray(mask_g * 255, 'uint8')
    
    os.system('mkdir ' + save_path + '/Mask_GlobalThrd_G/')
    cv2.imwrite(save_path + '/Mask_GlobalThrd_G/' +basename, mask_g)
    
    mask_r = img[:,:,2] > GlobalThrd_R
    mask_r = remove_small_objects(mask_r, 100, connectivity=1)
    mask_r = np.asarray(mask_r * 255, 'uint8')
    
    os.system('mkdir ' + save_path + '/Mask_GlobalThrd_R/')
    cv2.imwrite(save_path + '/Mask_GlobalThrd_R/' +basename, mask_r)
    
def Injection_Detection_COM_G(mask_path):
    #print mask_path
    basename = os.path.basename(mask_path)
    mask = cv2.imread(mask_path, -1)

    blocks = GetBlockList(mask.shape[0], mask.shape[1], 0)
    contour_mask = np.zeros((mask.shape[0], mask.shape[1]))
    
    for block in blocks:
        sub = mask[block[0]:block[1], block[2]:block[3]]
        if sub.sum() > 256*256*0.02*255:#2%
            contour_mask[block[0]:block[1], block[2]:block[3]] = 255
    os.system('mkdir ' + save_path + '/Mask_Contour_G/')
    cv2.imwrite(save_path + '/Mask_Contour_G/'+ basename, contour_mask)
    
    #######################
    contour_mask = contour_mask > 1
    contour_mask = np.asarray(contour_mask * 1,'float64')

    m = contour_mask
    m = m / np.sum(np.sum(m))

    # marginal distributions
    dx = np.sum(m, 1)
    dy = np.sum(m, 0)

    # expected values
    cx = np.sum(dx * np.arange(mask.shape[0]))
    cy = np.sum(dy * np.arange(mask.shape[1]))
    
    file = open(save_path+'/Metadata_G/'+basename+'.txt', 'a')
    file.write("Center of Mass X: \r\n")
    file.write(str(cx)+'\r\n')
    file.write("Center of Mass Y: \r\n")
    file.write(str(cy)+'\r\n')
    file.write('Contour Size(pixels):\r\n')
    file.write(str(contour_mask.sum()))
    file.close()

def Injection_Detection_COM_R(mask_path):
    #print mask_path
    basename = os.path.basename(mask_path)
    mask = cv2.imread(mask_path, -1)

    blocks = GetBlockList(mask.shape[0], mask.shape[1], 0)
    contour_mask = np.zeros((mask.shape[0], mask.shape[1]))
    
    for block in blocks:
        sub = mask[block[0]:block[1], block[2]:block[3]]
        if sub.sum() > 256*256*0.02*255:#2%
            contour_mask[block[0]:block[1], block[2]:block[3]] = 255
    os.system('mkdir ' + save_path + '/Mask_Contour_R/')
    cv2.imwrite(save_path + '/Mask_Contour_R/'+ basename, contour_mask)
    
    #######################
    contour_mask = contour_mask > 1
    contour_mask = np.asarray(contour_mask * 1,'float64')

    m = contour_mask
    m = m / np.sum(np.sum(m))

    # marginal distributions
    dx = np.sum(m, 1)
    dy = np.sum(m, 0)

    # expected values
    cx = np.sum(dx * np.arange(mask.shape[0]))
    cy = np.sum(dy * np.arange(mask.shape[1]))
    
    file = open(save_path+'/Metadata_R/'+basename+'.txt', 'a')
    file.write("Center of Mass X: \r\n")
    file.write(str(cx)+'\r\n')
    file.write("Center of Mass Y: \r\n")
    file.write(str(cy)+'\r\n')
    file.write('Contour Size(pixels):\r\n')
    file.write(str(contour_mask.sum()))
    file.close()

#downsample first
from skimage.util import view_as_blocks
import numpy as np
def Down_Sample(image, block_size, func=np.sum, cval=0):

    if len(block_size) != image.ndim:
        raise ValueError("`block_size` must have the same length "
                         "as `image.shape`.")

    pad_width = []
    for i in range(len(block_size)):
        if block_size[i] < 1:
            raise ValueError("Down-sampling factors must be >= 1. Use "
                             "`skimage.transform.resize` to up-sample an "
                             "image.")
        if image.shape[i] % block_size[i] != 0:
            after_width = block_size[i] - (image.shape[i] % block_size[i])
        else:
            after_width = 0
        pad_width.append((0, after_width))

    image = np.pad(image, pad_width=pad_width, mode='constant',
                   constant_values=cval)

    out = view_as_blocks(image, block_size)

    for i in range(len(out.shape) // 2):
        out = func(out, axis=-1)

    return out

def downsample(img):
    #print img_path
    #img = imread_fast(img_path)
    
    imgT1_B, imgT1_G, imgT1_R = cv2.split(img)
    imgT1_B = Down_Sample(cv2.GaussianBlur(imgT1_B,(7,7),0), ((2,2)), func=np.max)
    imgT1_G = Down_Sample(cv2.GaussianBlur(imgT1_G,(7,7),0), ((2,2)), func=np.max)
    imgT1_R = Down_Sample(cv2.GaussianBlur(imgT1_R,(7,7),0), ((2,2)), func=np.max)
    imgT1 = cv2.merge([imgT1_B, imgT1_G, imgT1_R])
    
    imgT2_B = Down_Sample(cv2.GaussianBlur(imgT1_B,(7,7),0), ((2,2)), func=np.mean)
    imgT2_G = Down_Sample(cv2.GaussianBlur(imgT1_G,(7,7),0), ((2,2)), func=np.mean)
    imgT2_R = Down_Sample(cv2.GaussianBlur(imgT1_R,(7,7),0), ((2,2)), func=np.mean)
    imgT2 = cv2.merge([imgT2_B, imgT2_G, imgT2_R])
    
    imgT3_B = Down_Sample(cv2.GaussianBlur(imgT2_B,(7,7),0), ((2,2)), func=np.max)
    imgT3_G = Down_Sample(cv2.GaussianBlur(imgT2_G,(7,7),0), ((2,2)), func=np.max)
    imgT3_R = Down_Sample(cv2.GaussianBlur(imgT2_R,(7,7),0), ((2,2)), func=np.max)
    imgT3 = cv2.merge([imgT3_B, imgT3_G, imgT3_R])

    #imgT4_B = Down_Sample(cv2.GaussianBlur(imgT3_B,(7,7),0), ((2,2)), func=np.max)
    #imgT4_G = Down_Sample(cv2.GaussianBlur(imgT3_G,(7,7),0), ((2,2)), func=np.max)
    #imgT4_R = Down_Sample(cv2.GaussianBlur(imgT3_R,(7,7),0), ((2,2)), func=np.max)
    #imgT4 = cv2.merge([imgT4_B, imgT4_G, imgT4_R])
    
    #basename = os.path.basename(img_path)
    #cv2.imwrite('/scratch/PMD2448_downsample/' + basename, ImgTo8_render(imgT4))
    return imgT3

def single(img, basename):
    img = downsample(img)
    
    b, g, r = cv2.split(img)
    mask = b > 255
    b[mask] = 255
    mask = g > 255
    g[mask] = 255
    mask = r > 255
    r[mask] = 255
    
    img = cv2.merge([b,g,r])
    
    img = np.asarray(img, 'uint8')
    
    cv2.imwrite(save_path + '/Downsampled_img/' + basename, img)

def Injection_Detect_Pipeline(PMD_path, color = 'GRN'):
    
    img_path_list = natural_sort(glob.glob(PMD_path+'*.jp2'))
    os.system('mkdir '+save_path)
    print 'Downsampling......'
    os.system('mkdir '+save_path + '/Downsampled_img')
    
    
    print 'Finding local otsu......'
    p = Pool(10)
    p.map(Injection_Detection_thrd, img_path_list)
    
    print 'Finding global otsu......'
    GlobalThrd_G = Injection_Detection_Globalthrd(save_path + '/Metadata_G/')
    GlobalThrd_R = Injection_Detection_Globalthrd(save_path + '/Metadata_R/')
    print GlobalThrd_G
    print GlobalThrd_R
    print 'Applying global otsu......'
    func = partial(Injection_Detection_mask, GlobalThrd_G, GlobalThrd_R)
    p.map(func, img_path_list)
    
    print 'Calculate contour/Center of Mass/size'
    
    mask_path_list = natural_sort(glob.glob(save_path + '/Mask_GlobalThrd_G/' + '*.jp2'))
    p=Pool(10)
    p.map(Injection_Detection_COM_G, mask_path_list)
    
    mask_path_list = natural_sort(glob.glob(save_path + '/Mask_GlobalThrd_R/' + '*.jp2'))
    p=Pool(10)
    p.map(Injection_Detection_COM_R, mask_path_list)
    
def main():    
    print strftime("%Y-%m-%d %H:%M:%S", gmtime())
    os.system('mkdir '+save_path)
    injection_pixel_thrd = 500000
    Injection_Detect_Pipeline(input_path)
    print strftime("%Y-%m-%d %H:%M:%S", gmtime())

if __name__ == "__main__":
    os.system('export LD_LIBRARY_PATH=/sonas-hs/mitra/hpc/home/xli/KAKADU/lib/Linux-x86-64-gcc/')
    input_path = sys.argv[1]
    save_path = sys.argv[2]
    main()