#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 12 15:08:42 2019

Create lists of currently available CMIP6 data

PJD 29 Dec 2019     - Updated to describe model counts and added DAMIP
PJD 22 Jan 2020     - Updated to compare the AR5 vs AR6 CMIP5 data holdings

@author: durack1
"""

import datetime,glob,os
os.sys.path.insert(0,'/export/durack1/git/durolib/durolib')
from durolib import writeToLog

#%% Toggle which list to generate
cmip6 = False
cmip5 = True

#%% Create all defaults
xmlPath = '/p/user_pub/xclim/' ; #'/data_crunchy_oceanonly/crunchy_work/cmip-dyn'
mip = 'CMIP6'
activityExperimentId = {'one':['CMIP','historical'],'two':['DAMIP','hist-nat'],'three':['DAMIP','hist-GHG']}
realm = 'ocean'
frequency = 'mon'
variableId = ['so','sos','thetao','tos']
fileLists = []

#%% Set current dir
workDir = '/work/durack1/Shared/190311_AR6/Chap3'

#%% Process variables
if cmip6:
    timeNow = datetime.datetime.now();
    timeFormat = timeNow.strftime("%y%m%dT%H%M%S")
    logFile1 = os.path.join(workDir,'_'.join([timeFormat,'DataAvailableLog.txt']))
    for expCount,expInfo in enumerate(activityExperimentId):
        activityId = activityExperimentId[expInfo][0]
        experimentId = activityExperimentId[expInfo][1]
        print(activityId,':',experimentId)
        writeToLog(logFile1,' '.join([activityId,':',experimentId]))
        for var in variableId:
            timeNow = datetime.datetime.now();
            timeFormat = timeNow.strftime("%y%m%dT%H%M%S")
            idString1 = ' '.join(['MIP:',mip,'Activity Id:',activityId,'Experiment:',experimentId,'Variable:',var])
            idString2 = ' '.join([mip,activityId,experimentId,var])
            logFile2 = os.path.join(workDir,'_'.join([timeFormat,idString2.replace(' ','_'),'DataAvailableLog.txt']))
            writeToLog(logFile2,timeFormat)
            writeToLog(logFile2,idString1)
            searchPath = os.path.join(xmlPath,mip,activityId,experimentId,realm,frequency,var,'*.xml')
            print('searchPath:',searchPath)
            writeToLog(logFile2,' '.join(['searchPath:',searchPath]))
            writeToLog(logFile1,' '.join(['searchPath:',searchPath]))
            fileList = glob.glob(searchPath) ; fileList.sort()
            for count,filePath in enumerate(fileList):
                #print(count,filePath.split('/')[-1])
                strTxt = filePath.split('/')[-1]
                strTxt = strTxt.replace('.0000000.0.xml','')
                print('{:03d}'.format(count+1),strTxt)
                writeToLog(logFile2,' '.join(['{:03d}'.format(count+1),strTxt]))
            print('-----')
            # Create subset list of models
            modLists = []
            for count,filePath in enumerate(fileList):
                strTxt = filePath.split('/')[-1]
                mod = strTxt.split('.')[4]
                if mod not in modLists:
                    modLists.append(mod)
                    #print('mod:',strTxt.split('.')[4])
            modLists.sort()
            for count,mod in enumerate(modLists):
                print('{:02}'.format(count+1),mod)
                writeToLog(logFile1,' '.join(['{:02}'.format(count+1),mod]))

#%% Process CMIP5-AR5 vs CMIP5-AR6 comparisons
if cmip5:
    # Set data paths
    cm5AR5Path = '/work/durack1/Shared/120711_AR5/Chap09/ncs/130522'
    #cmip5.ACCESS1-0.historical.r1i1p1.an.ocn.so.ver-1.1975-2005_anClim_WOAGrid
    cm5AR6Path = '/work/durack1/Shared/190311_AR6/Chap3/ncs/CMIP5/historical/woaGrid'
    #CMIP6.CMIP.historical.UA.MCM-UA-1-0.r1i1p1f2.mon.thetao.ocean.glb-l-gn.v20190731.1984-2014-woaClim
    for var in ['so','thetao']:
        vars()[''.join(['ar5',var])] = glob.glob(os.path.join(cm5AR5Path,var,'*.nc'))
        vars()[''.join(['ar6',var])] = glob.glob(os.path.join(cm5AR6Path,''.join(['*.',var,'.*.nc'])))
    # Now pull out model.realisation from AR5 paths
    ar5soL,ar5thetaoL,ar6soL,ar6thetaoL = [[] for _ in range(4)]
    for paths in ar5so:
        tmp = paths.split('/')[-1].split('.')
        ar5soL.append('.'.join([tmp[1],tmp[3]])) #,tmp[7].replace('ver-','')]))
    for paths in ar5thetao:
        tmp = paths.split('/')[-1].split('.')
        ar5thetaoL.append('.'.join([tmp[1],tmp[3]])) #,tmp[7].replace('ver-','')]))
    for paths in ar6so:
        tmp = paths.split('/')[-1].split('.')
        ar6soL.append('.'.join([tmp[4],tmp[5]])) #,tmp[10].replace('ver-','')]))
    for paths in ar6thetao:
        tmp = paths.split('/')[-1].split('.')
        ar6thetaoL.append('.'.join([tmp[4],tmp[5]])) #,tmp[10].replace('ver-','')]))
    del(paths,tmp,var)
    # Sort all lists
    ar5soL.sort(); ar5thetaoL.sort(); ar6soL.sort(); ar6thetaoL.sort()
    # Remove all dupes
    ar5soL = list(set(ar5soL)); ar5soL.sort()
    ar5thetaoL = list(set(ar5thetaoL)); ar5thetaoL.sort()
    ar6soL = list(set(ar6soL)); ar6soL.sort()
    ar6thetaoL = list(set(ar6thetaoL)); ar6thetaoL.sort()
    # Write lists out to files
    timeNow = datetime.datetime.now();
    timeFormat = timeNow.strftime("%y%m%dT%H%M%S")
    ar5soLog = os.path.join(workDir,'_'.join([timeFormat,'ar5soLog.txt']))
    for count,modReal in enumerate(ar5soL):
        #writeToLog(ar5soLog,' '.join(['{:03d}'.format(count+1),modReal]))
        writeToLog(ar5soLog,modReal)
    ar5thetaoLog = os.path.join(workDir,'_'.join([timeFormat,'ar5thetaoLog.txt']))
    for count,modReal in enumerate(ar5thetaoL):
        #writeToLog(ar5thetaoLog,' '.join(['{:03d}'.format(count+1),modReal]))
        writeToLog(ar5thetaoLog,modReal)
    ar6soLog = os.path.join(workDir,'_'.join([timeFormat,'ar6soLog.txt']))
    for count,modReal in enumerate(ar6soL):
        #writeToLog(ar6soLog,' '.join(['{:03d}'.format(count+1),modReal]))
        writeToLog(ar6soLog,modReal)
    ar6thetaoLog = os.path.join(workDir,'_'.join([timeFormat,'ar6thetaoLog.txt']))
    for count,modReal in enumerate(ar6thetaoL):
        #writeToLog(ar6thetaoLog,' '.join(['{:03d}'.format(count+1),modReal]))
        writeToLog(ar6thetaoLog,modReal)

