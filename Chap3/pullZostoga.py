#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 15 14:10:42 2020

Paul J. Durack 15th December 2020

This script pulls and pools zostoga output for Ch3

PJD 16 Dec 2020 - Finalized with zip archive
PJD  5 Feb 2021 - Updated to remove existing archive if it exists
PJD  5 Feb 2021 - Add tmp file migration to persistent workDir
PJD 29 Mar 2021 - Add logs so directory version numbers are preserved

@author: durack1
"""
import datetime, glob, os, pdb, re, zipfile
from shutil import copytree, make_archive, move, rmtree
os.sys.path.insert(0,'/export/durack1/git/durolib/durolib')
from durolib import writeToLog #,trimModelList

#%% Setup inputs
exps = {}
exps['DAMIP'] = ['hist-GHG', 'hist-aer', 'hist-nat']
exps['CMIP'] = ['historical', 'piControl']
# /p/css03/esgf_publish/CMIP6/CMIP/CCCma/CanESM5/historical/r1i1p1f1/Omon/zostoga/gn/v20190429/
path = '/p/css03/esgf_publish/CMIP6/activity_id/institution_id/source_id/experiment_id/RIPF_id/Omon/zostoga/grid_id/version_id'
wilds = ['RIPF_id', 'grid_id', 'institution_id', 'source_id', 'version_id']
timeFormat = datetime.datetime.now()
timeFormat = timeFormat.strftime("%y%m%d_durack1")
print('timeFormat:', timeFormat)

#%% Start - add wildcards
pathTmp = path
print('pathTmp:',pathTmp)
for wild in wilds:
    pathTmp = pathTmp.replace(wild,'*')
print('pathTmp:',pathTmp)

#%% Loop through act_id, source_id pairs
filePaths = []
for act in exps.keys():
    actId = act
    print('actId:', actId)
    for exp in exps[actId]:
        print('actId:', actId, 'expId:', exp)
        pathSearch = pathTmp.replace('activity_id', actId)
        pathSearch = pathSearch.replace('experiment_id',exp)
        print('pathSearch:',pathSearch)
        filePaths.extend(glob.glob(pathSearch))
print('----- -----')

#%% Find dupe versions and trim
filePaths.sort()
filePathsLen = len(filePaths)
filePathsKeep = []
reaTest = re.compile('v\d{1,8}')
for count, filePath in enumerate(filePaths):
    a = filePath
    ind = a.rfind('/')
    if count < filePathsLen-1:
        b = filePaths[count+1]
    else:
        b = ['']
        continue
    aVer = re.findall(reaTest,a)
    aStrip = a.replace(aVer[0],'')
    bVer = re.findall(reaTest,b)
    bStrip = b.replace(bVer[0],'')
    if not aStrip == bStrip:
        filePathsKeep.extend([a])

#%% Use filePathsKeep and start collating data
targetDir = '/tmp'
# Make dir
targetDirComp = os.path.join(targetDir, timeFormat)
print('targetDirComp:', targetDirComp)

# Manage existing dir
if os.path.exists(targetDirComp):
    rmtree(targetDirComp)
os.makedirs(targetDirComp)
os.chdir(targetDirComp)
print('os.getcwd():', os.getcwd())

# Create log
timeNow = datetime.datetime.now();
timeFormat = timeNow.strftime("%y%m%dT%H%M%S")
dateNow = timeNow.strftime('%y%m%d')
#dateNow = '210226'
logFile = os.path.join(targetDirComp,'_'.join([timeFormat,'AR6WG1-Ch3-CMIP6-zostoga_log.txt']))
textToWrite = ' '.join(['TIME:',timeFormat])
writeToLog(logFile,textToWrite)

# Loop through directories and copy paths and data
for count, filepath in enumerate(filePathsKeep):
    print(count, filepath)
    filePathTrim = filepath.split('/')[4:]
    filePathTrim = os.path.join(*filePathTrim)
    print('filePathTrim: ',filePathTrim)
    writeToLog(logFile,' '.join(["{:03d}".format(count), filePathTrim]))
    dest = filepath.split('/')
    dest = dest[4:]
    dest = os.path.join(*dest)
    copytree(filepath, dest)
    print('copytree(', filepath, dest,')')

#%% Append log file
os.rename(logFile,logFile.replace(targetDirComp,os.path.join(targetDirComp,'CMIP6')))

#%% Zip up for distribution
zipFile = '_'.join([timeFormat, 'CMIP6-CMIP-DAMIP-zostoga'])
zipFilePath = os.path.join(targetDirComp, zipFile)
zipFileExt = '.'.join([zipFilePath,'zip'])
if os.path.exists(zipFileExt):
    os.remove(zipFileExt)
print('zipFile:', zipFilePath)
os.chdir('..') ; # jump one dir up, so not to self-reference zip archive
#make_archive(zipFilePath, 'zip', '.', '.')
make_archive(zipFilePath, 'zip', targetDirComp, 'CMIP6')

#%% Move to Chap3 directory
workDir = '/work/durack1/Shared/190311_AR6/Chap3'
zipFileExtMoved = os.path.join(workDir,'.'.join([zipFile,'zip']))
print('zipFileExtMoved:',zipFileExtMoved)
move(zipFileExt,zipFileExtMoved)
