#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Nov 12 15:08:42 2019

Create lists of currently available CMIP6 data

PJD 29 Dec 2019     - Updated to describe model counts and added DAMIP

@author: durack1
"""

import datetime,glob,os
os.sys.path.insert(0,'/export/durack1/git/durolib/durolib')
from durolib import writeToLog

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