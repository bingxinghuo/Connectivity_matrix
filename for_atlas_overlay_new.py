import csv
import json
import sys
import os
import re
import subprocess
from cStringIO import StringIO
from collections import defaultdict

import nibabel as nib
import numpy as np
import parseSlideNumbers

from PIL import Image
from lxml import etree


import svgpathparse

patientnumber = sys.argv[1]
singlestartind = int(sys.argv[2])
singleendind = int(sys.argv[3])

re_color = re.compile(r'#' + r'([0-9a-f][0-9a-f])' * 3, re.I)
re_fill = re.compile(r'fill: ?(#' + r'[0-9a-f][0-9a-f]' * 3 + ')', re.I)

def pascal_row(n):
    # This returns the nth row of Pascal's Triangle
    result = [1]
    x, numerator = 1, n
    for denominator in range(1, n//2+1):
        # print(numerator,denominator,x)
        x *= numerator
        x /= denominator
        result.append(x)
        numerator -= 1
    if n&1 == 0:
        # n is even
        result.extend(reversed(result[:-1]))
    else:
        result.extend(reversed(result))
    return result

def make_bezier(xys):
    # xys should be a sequence of 2-tuples (Bezier control points)
    n = len(xys)
    combinations = pascal_row(n-1)
    def bezier(ts):
        # This uses the generalized formula for bezier curves
        # http://en.wikipedia.org/wiki/B%C3%A9zier_curve#Generalization
        result = []
        for t in ts:
            tpowers = (t**i for i in range(n))
            upowers = reversed([(1-t)**i for i in range(n)])
            coefs = [c*a*b for c, a, b in zip(combinations, tpowers, upowers)]
            result.append(
                tuple(sum([coef*p for coef, p in zip(coefs, ps)]) for ps in zip(*xys)))
        return result
    return bezier

ts = [t/10. for t in range(11)]

nii = nib.load('../Reconstruction/m'+ patientnumber +'/registration/M' + patientnumber + '_annotation.img')
pixdim = nii.header['pixdim']
Sx, Sy = pixdim[1], pixdim[3]

print 'Sx, Sy', Sx, Sy

np.set_printoptions(threshold='nan')
print nii.get_data().shape
shape = nii.get_data().shape

color_lookup = {}
color_rev_lookup = {}
with open('ColorLUT.ctbl', 'rb') as f:
    csv_reader = csv.reader(f, delimiter=' ')
    next(csv_reader)
    for l in csv_reader:
        #print l[0], l[1], l[2], l[3], l[4]
        index = int(l[0])
        color_lookup[index] = (l[1], int(l[2]), int(l[3]), int(l[4]))
        color_rev_lookup[(int(l[2]), int(l[3]), int(l[4]))] = l[1]
color_lookup[10000] = color_lookup[0]
try:
    os.mkdir('data')
except OSError:
    pass

def return_color(idx):
    if idx == 10000:
        return 0
    res = color_lookup[idx]
    ret = (res[1] << 16) + (res[2] << 8) + res[3]
    return ret

# retrive list of nissl and fluro for comparsion using parseSlideNumbers.py
(nissldirectorylist, nisslnamelist, nissllist) = parseSlideNumbers.parse('BNBLists/M' + patientnumber + "_" + str.upper('N') + '_List.txt',singlestartind,singleendind,patientnumber)
#maxslicenumber = np.max((np.array(aavlist).max(),np.array(nissllist).max()))
filenamesfilt_nissl = list(nisslnamelist)

for idx in range(shape[1]):
    print 'working on index', idx
    #mm_per_px = 0.00368
    mm_per_px = 0.00368 / 4
    Coef = (Sx / mm_per_px, - Sy / mm_per_px)
    offset_x = offset_y = 0

    # try:
    #     os.mkdir('data/%s' % idx)
    # except OSError:
    #     pass

    buff = StringIO()
    svg_file = '%d.svg' % idx
    arr = nii.get_data()[:, idx, :]
    arr = arr.astype(np.int16)
    #unique, counts = np.unique(arr, return_counts=True)


    #print dict(zip(unique, counts))
    arr = np.fliplr(arr)
    arr = np.rot90(arr)
    w, h = arr.shape

    #color_arr = np.fromiter((return_color(arr_id) for arr_id in arr), np.int32)
    #print color_arr
    image_arr = np.zeros((h, w, 3), np.uint8)
    image_arr[..., 0] = np.right_shift(arr, 8).T
    image_arr[..., 1] = np.bitwise_and(arr, 0xff).T
    image_arr[..., 2] = 0

    color_func = np.vectorize(return_color, otypes=[np.uint32])
    color_arr = color_func(arr)

    display_arr = np.zeros((h, w, 3), np.uint8)
    display_arr[..., 0] = np.bitwise_and(np.right_shift(color_arr, 16), 0xff).T
    display_arr[..., 1] = np.bitwise_and(np.right_shift(color_arr, 8), 0xff).T
    display_arr[..., 2] = np.bitwise_and(color_arr, 0xff).T

    #print display_arr.shape
    #arr = arr.astype(np.uint8)
    im = Image.fromarray(image_arr)
    im.save(buff, 'PNG')

    im_color = Image.fromarray(display_arr)
    #print im_color

    #svg_path = os.path.join('data', '%s' % idx, svg_file)
    svg_path = os.path.join('data',  svg_file)
    #p = subprocess.Popen(['/usr/local/bin/mindthegap', '-t', '1', '-i', '-', '-o', svg_path], stdin=subprocess.PIPE)
    #p = subprocess.Popen(['/usr/local/bin/mindthegap', '-t', '1', '-i', '-', '-o', svg_path], stdin=subprocess.PIPE)
    p = subprocess.Popen(['/usr/local/bin/mindthegap', '-t', '1', '-c', '#000000', '-i', '-', '-o', svg_path], stdin=subprocess.PIPE)
    p.stdin.write(buff.getvalue())
    p.communicate()

    tree = etree.parse(svg_path)
    doc = tree.getroot()
    ns_svg = doc.nsmap[None]
    parcellation = defaultdict(list)
    for p in doc.xpath('//svg:path', namespaces={'svg': ns_svg}):
        last = None
        line_coords = []

        line_coord = []
        _first_line = False
        color = p.get('fill')
        if color is None:
            style = p.get('style')
            m = re_fill.search(style)
            color = m.group(1)

        if color:
            m = re_color.match(color)
            r, g, b = m.groups()
            id_ = (int(r, 16) << 8) + (int(g, 16))
            if id_ == 4872:
                id_ = 0
        

            area_info = color_lookup[id_]
            # set the Area name here as id
            p.set('id', area_info[0])
            # set the stroke width here
            p.set('stroke-width', '1')
            color_hex = '#%02x%02x%02x' % (area_info[1], area_info[2], area_info[3])
            ############################################################################################
            #p.set('fill', color_hex)
            if color_hex == '#000000':
                p.set('fill', color_hex)
                p.set('stroke', color_hex)
            else:
                p.set('fill', '#808080')
                #p.set('stroke', color_hex)
                p.set('stroke','#808080')



            if id_ == 0 or id_ == 10000:
                continue
            else:
                #id_ = int(r, 16)
                d = svgpathparse.parsePath(p.get('d'))
                for cmd, vertices in d:
                    if cmd == 'Z':
                        # do nothing, the polygon algorithm should handle this better
                        pass
                        #line_coord.append(line_coord[0])
                    elif cmd == 'M':
                        last = vertices
                        _first_line = True
                        if len(line_coord) > 0:
                            line_coords.append([[_x * Coef[0], _y * Coef[1]] for _x, _y in line_coord])
                            line_coord = []
                    elif cmd == 'L':
                        if _first_line:
                            line_coord.append(tuple(last))
                            _first_line = False
                        line_coord.append(tuple(vertices))
                        last = vertices
                    elif cmd == 'C':
                        x0, y0, x1, y1, x2, y2 = vertices
                        if last is not None:
                            bezier = make_bezier([last, (x0, y0), (x1, y1), (x2, y2)])
                        else:
                            bezier = make_bezier([(x0, y0), (x1, y1), (x2, y2)])
                        last = (x2, y2)
                        line_coord.extend(bezier(ts))
                    else:
                        raise ValueError('unhandled path cmd', cmd)
                if len(line_coord) > 0:
                    line_coords.append([[_x * Coef[0], _y * Coef[1]] for _x, _y in line_coord])
            res = color_lookup[id_]
            parcellation[id_].append({'coords': line_coords, 'index': id_, 'area': res[0], 'color': '#%02x%02x%02x' % (res[1], res[2], res[3])})
    #im.save('data/%d.svg' % idx, 'PNG')
    #im_color.save('data/%d_color.png' % idx, 'PNG')
    features = []
    for f_list in parcellation.values():
        for f in f_list:
            features.append({
                'type': 'feature',
                'id': f['index'],
                'properties': {
                    'name': f['area'],
                    'acronym': f['area'],
                    'color': f['color'],
                },
                'geometry': {
                    'type': 'Polygon',
                    'coordinates': f['coords'],
                    },
                })
            geo_json = {
                    'type': 'FeatureCollection',
                    'features': features
                    }

    if(idx > 40 and idx < max(range(shape[1]))-15):
        array_in_idx_for_filename = idx - 41
        print "retrive filename index", array_in_idx_for_filename

        if(array_in_idx_for_filename in nissllist):
            print nisslnamelist[nissllist.index(array_in_idx_for_filename)]
            with open('data/%s.json' % nisslnamelist[nissllist.index(array_in_idx_for_filename)], 'wb') as f:
            #with open('data/%s.json' % nisslnamelist[array_in_idx_for_filename], 'wb') as f:
                try:
                    json.dump(geo_json, f)
                except NameError:
                    print "geo_json not defined - indx skip: ", idx
            
             #print json.dumps(line_coord)
