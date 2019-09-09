#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Thu Oct  4 16:19:08 2018

@author: bingxinghuo
"""
import sys
import parseSlideNumbers
import csv

animalid=sys.argv[1]
seriesid=sys.argv[2]
filedirectory=sys.argv[3]
savedirectory=sys.argv[4]
singlestart=int(sys.argv[5])
singleend=int(sys.argv[6])

(directorynamelist, filenamelist, truenumberlist)  = parseSlideNumbers.parse(filedirectory+'/filenames.txt',singlestart,singleend,animalid)

rows=zip(filenamelist,truenumberlist)
savefile=savedirectory+'/'+animalid+seriesid+'_anno_seclist.csv'
with open(savefile,'wb') as f:
    writer=csv.writer(f)
    for row in rows:
        writer.writerow(row)
