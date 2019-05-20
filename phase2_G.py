#phase 2, snake, Green

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

def natural_sort(l): 
    convert = lambda text: int(text) if text.isdigit() else text.lower() 
    alphanum_key = lambda key: [ convert(c) for c in re.split('([0-9]+)', key) ] 
    return sorted(l, key = alphanum_key)

def Injection_Detection_FindRange(metadata_path):
    metadata_path_list = natural_sort(glob.glob(metadata_path + '*.txt'))
    size_list = []
    for ii in metadata_path_list:
        f = open(ii)
        lines = f.readlines()
        size_list.append(lines[7])
    size_list = np.asarray(size_list, 'float64')
    size_list = size_list > injection_pixel_thrd
    size_list = np.array(size_list * 1)
    return size_list

def Good_Neighbor(ary):
    n = len(ary)
    index_list = []
    for i in range(1, n-2):
        if ary[i] == 1:
            index_list.append(i)
    for ii in index_list:
        ary[ii -1] = 1
        ary[ii +1] = 1
    return ary
def Longest_Sublist(ary):
    n = len(ary)
    count = 0
    result = 0
    index_begin = 0
    for i in range(n):
        if ary[i] == 0:
            count = 0
        else:
            count = count + 1
            result = np.max([result, count])
            if result == count:
                index_begin = i
    return result, index_begin-result+1

def Injection_Detection_SNAKE_G(img_path):
    img = cv2.imread(img_path, -1)
    basename = os.path.basename(img_path)
    print basename
    
    f = open(save_path + '/Metadata_G/' + basename +'.txt')
    lines = f.readlines()
    CoM_X = np.rint(float(lines[3]))
    CoM_Y = np.rint(float(lines[5]))
    CoM_X = int(CoM_X)
    CoM_Y = int(CoM_Y)

    s = np.linspace(0, 2*np.pi, 200)
    #x = CoM_Y + 2000*np.cos(s)
    #y = CoM_X + 2000*np.sin(s)
    #x = 1000 + 2000*np.cos(s)
    #y = 1000 + 2000*np.sin(s)
    #init = np.array([x, y]).T

    subimg = img[CoM_X-1000:CoM_X+1000, CoM_Y-1000:CoM_Y+1000]
    
    ###local center of mass:
    contour_mask = subimg > 1
    contour_mask = np.asarray(contour_mask * 1,'float64')

    m = contour_mask
    m = m / np.sum(np.sum(m))

    # marginal distributions
    dx = np.sum(m, 1)
    dy = np.sum(m, 0)
    # expected values    
    cx = np.sum(dx * np.arange(subimg.shape[0]))
    cy = np.sum(dy * np.arange(subimg.shape[1]))
    ###local center of mass done
    
    x = cy + 1000*np.cos(s)
    y = cx + 1000*np.sin(s)
    init = np.array([x, y]).T
    
  
  

    fig, ax = plt.subplots(figsize=(15, 15))
    ax.imshow(img, cmap=plt.cm.gray)
    ax.plot(init[:, 0] + CoM_Y - 1000, init[:, 1] + CoM_X - 1000, '--r', lw=1)
    snake = active_contour(subimg, init, alpha=0.015, beta=1, gamma=0.001, max_iterations=3000)
    ax.plot(snake[:, 0] + CoM_Y - 1000, snake[:, 1] + CoM_X - 1000, '-b', lw=2)
    
    os.system('mkdir '+save_path+'/InjectionSite_SNAKE_G/')
    plt.savefig(save_path + '/InjectionSite_SNAKE_G/' + basename + '.tif')
    
    
    fig, ax = plt.subplots(figsize=(15, 15))
    blackimg = np.zeros((img.shape[0],img.shape[1]))
    ax.imshow(blackimg, cmap=plt.cm.gray)
    ax.plot(init[:, 0] + CoM_Y - 1000, init[:, 1] + CoM_X - 1000, '--r', lw=1)
    ax.plot(snake[:, 0] + CoM_Y - 1000, snake[:, 1] + CoM_X - 1000, '-b', lw=1)
    
    os.system('mkdir '+save_path+'/InjectionSite_SNAKE_only_G')
    plt.savefig(save_path + '/InjectionSite_SNAKE_only_G/' + basename + '.tif')
    
    os.system('mkdir '+save_path + '/InjectionSite_SNAKE_datapoints_G')
    init[:, 0] = init[:, 0] + CoM_Y - 1000
    init[:, 1] = init[:, 1] + CoM_X - 1000
    snake[:, 0] = snake[:, 0] + CoM_Y - 1000
    snake[: ,1] = snake[:, 1] + CoM_X - 1000
    #save the data points
    pickle.dump(init, open(save_path + '/InjectionSite_SNAKE_datapoints_G/' + basename + '_init_G.p','wb'))
    pickle.dump(snake,open(save_path + '/InjectionSite_SNAKE_datapoints_G/' + basename + '_snake_G.p','wb'))


def Injection_Detect_Pipeline(PMD_path, color = 'GRN'):
    
    ###find the possible list of injection images:
    print 'Finding the interesting images stack - G'
    mask_path_list = natural_sort(glob.glob(save_path + '/Mask_GlobalThrd_G/' + '*.jp2'))#
    
    injct_binary = Injection_Detection_FindRange(save_path + '/Metadata_G/')
    #injct_binary = Good_Neighbor(injct_binary)
    length, starting_index = Longest_Sublist(injct_binary)
    injct_path_list = []  #The list of image will be processed by SNAKE, possible injection site images.
    for i in range(starting_index, starting_index + length):
        injct_path_list.append(mask_path_list[i])
        #print mask_path_list[i]
    injct_path_list.append(mask_path_list[i + 1])
    injct_path_list.append(mask_path_list[i + 2])
    injct_path_list.append(mask_path_list[starting_index - 1])
    injct_path_list.append(mask_path_list[starting_index - 2])
    
    print 'Watchout for SNAKE! - G'
    print injct_path_list
    #Use SNAKE method to draw the contour
    p = Pool(6)
    p.map(Injection_Detection_SNAKE_G, injct_path_list)

def main():    
    print strftime("%Y-%m-%d %H:%M:%S", gmtime())
    os.system('mkdir '+save_path)
    Injection_Detect_Pipeline(input_path)
    print strftime("%Y-%m-%d %H:%M:%S", gmtime())

if __name__ == "__main__":
    injection_pixel_thrd = 400000
    os.system('export LD_LIBRARY_PATH=/sonas-hs/mitra/hpc/home/xli/KAKADU/lib/Linux-x86-64-gcc/')
    input_path = sys.argv[1]
    save_path = sys.argv[2]
    main()
    
    
