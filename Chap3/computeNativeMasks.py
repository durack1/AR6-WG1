#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr 24 16:08:19 2017

PJD 25 Apr 2017     - Started
PJD 25 Apr 2017     - Updated to basinmask4
PJD 28 Apr 2017     - Updated to use sftlf as first pass
PJD  1 May 2017     - Invert logic, map basinmask4 to target model grid
PJD  9 Feb 2018     - Updated to write ocean files
PJD 10 Feb 2018     - Updated to deal with matrix lon/lat grids
PJD  7 Nov 2019     - Copied file from /work/durack1/Shared/160202_PaperPlots_SaltyVariability/computeNativeMasks.py
PJD  7 Nov 2019     - Updated durolib path
PJD  8 Nov 2019     - Updated climlib after fix https://github.com/PCMDI/climlib/issues/2
PJD 14 Nov 2019     - Updated to deal with multiple mip_eras
PJD 14 Nov 2019     - Fixed issue with missing creation_date in wrangle, see https://github.com/PCMDI/climlib/issues/3
PJD 17 Nov 2019     - Updated to deal with CMIP5/6 variable lists
PJD 19 Nov 2019     - Updated to deal with CMIP5/6 variable lists dynamically
PJD 19 Nov 2019     - Updated to use pdb for debugging
PJD 19 Nov 2019     - Correct basinmask4 indexing to int (not int64)
PJD 20 Nov 2019     - Updated outPath directory creation code
PJD 20 Nov 2019     - Updated os.mkdir with os.makedirs - recursive option
PJD 20 Nov 2019     - General cleanup with backup code saved as *.bak191120
PJD 20 Nov 2019     - Updated to include argparse
PJD 20 Nov 2019     - Debug CMIP5 CMIP5.CMIP.historical.BNU.BNU-ESM.r0i0p0.fx.sftlf.atmos.glb-2d-gu.v20130507.0000000.0.xml issue (index = 5)
PJD 20 Nov 2019     - Updated index for model matching (filePath)
PJD 21 Nov 2019     - Debug CMIP5 CMIP5.CMIP.historical.BNU.BNU-ESM.r0i0p0.fx.sftof.ocean.glb-2d-gu.v20130507.0000000.0.xml (index = 20)
PJD 21 Nov 2019     - Added badFiles to append erroneous files to list
                    - TODO: Add in sftlf to query mask (if not == 0, land)
                    - TODO: Add sftlf/of and areacella/o to basinmask
                    - TODO: Deal with matrix grids (tos)

@author: durack1
"""

import argparse,gc,glob,os,sys,pdb #,time,pdb,
import cdms2 as cdm
import MV2 as mv
import numpy as np
from numpy import mod
sys.path.append('/export/durack1/git/durolib/durolib')
from durolib import globalAttWrite #,mkDirNoOSErr#,trimModelList
#np.set_printoptions(threshold=np.nan)
os.sys.path.insert(0,'/export/durack1/git/climlib/climlib')
#import climlib
from wrangle import trimModelList ; # climlib

#%% set cdms2 options
cdm.setNetcdfShuffleFlag(1)
cdm.setNetcdfDeflateFlag(1) ; # netCDF compression (use 0 for netCDF3)
cdm.setNetcdfDeflateLevelFlag(9) ; # 9(shuf=1) 466.6KB; 9(shuf=0) 504.1KB; 4(shuf=0) 822.93KB;
cdm.setAutoBounds(1)

#%% Initialize argparse
parser = argparse.ArgumentParser()
parser.add_argument('mipEra',help='CMIP era: either CMIP3, 5, or 6')
parser.add_argument('activityId',help='e.g. CMIP includes all DECK simulations; ScenarioMIP all projections')
parser.add_argument('experimentId',help='e.g. historical for CMIP5/6, 20c3m for CMIP3')
args = parser.parse_args()

if args.mipEra in ['CMIP5','CMIP6']:
    mipEra = args.mipEra
    print('mipEra:',mipEra)
if args.activityId in ['CMIP','ScenarioMIP']:
    activityId = args.activityId
    print('activityId:',activityId)
if args.experimentId in ['historical']:
    experimentId = args.experimentId
    print('experimentId:',experimentId)
# Test for entries
varsToTest = ['mipEra','activityId','experimentId']
for var in varsToTest:
    if var in locals().keys():
        pass
    else:
        print('Variable:',var,'unset, exiting..')
        sys.exit
#%% tests
'''
mipEra = 'CMIP5'
activityId = 'CMIP'
experimentId = 'historical'
'''

#%% Set local path
localPath = '/work/durack1/Shared/190311_AR6/Chap3'

#%% Get a list of input files
cmipHome = '/p/user_pub/xclim/'
realms = {'tas':'atmos','tos':'ocean','sftlf':'atmos','sftof':'ocean'}
for count,var in enumerate(realms):
    if 'sft' in var:
        path = os.path.join(cmipHome,mipEra,'fx',var)
    else:
        path = os.path.join(cmipHome,mipEra,activityId,experimentId,realms[var],'mon',var)
    #testPath = os.path.join(cmipHome,mip,actId,expId,realms[realm])
    print('path:',path)
    fileList = glob.glob(os.path.join(path,'*.xml')) ; fileList.sort() ; # Order by alphabet
    tmp = trimModelList(fileList) ; tmp.sort()
    vars()['_'.join([var,'fileList'])] = tmp
del(count,var,path,fileList,tmp); gc.collect()

#%% Truncate lists using known problem data - may not be necessary as masks are ignored
'''
badFiles = [
 '/p/user_pub/xclim/CMIP5/fx/sftof/CMIP5.CMIP.historical.BNU.BNU-ESM.r0i0p0.fx.sftof.ocean.glb-2d-gu.v20130507.0000000.0.xml', #191121
 ]
for badFile in badFiles:
    print('Removing:',badFile.split('/')[-1])
    if badFile in sftlf_fileList: sftlf_fileList.remove(badFile)
    if badFile in sftof_fileList: sftof_fileList.remove(badFile)
    if badFile in tas_fileList: tas_fileList.remove(badFile)
    if badFile in tos_fileList: tos_fileList.remove(badFile)
'''
#%% Truncate list through smart loop
for var in ['sftlf','sftof','tas','tos']:
    print('var:',var)
    listName = '_'.join([var,'fileList'])
    listVar = var
    listCount = '_'.join([var,'Count'])
    print('listName:',listName)
    vars()[listVar] = []
    vars()[listCount] = []
    for count,model in enumerate(eval(listName)):
        #print(count,model)
        modValue = model.split('/')[-1].split('.')[4]
        gridValue = model.split('/')[-1].split('.')[9]
        #print(count,modValue,gridValue)
        if modValue not in eval(listVar):
            #print('modValue:',modValue)
            vars()[listVar] += [modValue]
            vars()[listCount] += [count]
    # Now truncate original fullpath list for single model entries
    del(count,model,modValue,gridValue)
    vars()[listName] = [eval(listName)[i] for i in eval(listCount)]
del(var,listCount,listName,listVar)

#%% Create master lists - fix duplication
fileMasterList = sftlf_fileList;
fileMasterList.extend(sftof_fileList)
#fileMasterList_CMIP6 = sftlf_CMIP6_fileList
#fileMasterList_CMIP6.extend(sftof_CMIP6_fileList)
#fileMasterLists = ['fileMasterList_CMIP5','fileMasterList_CMIP6']

#%% Loop through files and determine closest grid point
for countY,filePath in enumerate(fileMasterList[20:]):
    print('filePath:',filePath)
    print(countY,filePath.split('/')[-1])
    # Determine variable and load
    var = filePath.split('/')[-1].split('.')[7] ; # Always same location
    #print 'Processing: ',filePath.split('/')[-1]
    fH = cdm.open(filePath)
    tmp = fH(var,time=slice(0,1),squeeze=1)
    # Determine longitude range and correct
    targetLats = tmp.getLatitude()
    targetLons = tmp.getLongitude()
    # Test for valid grid
    if targetLats.getValue().min() >= 0:
        model = filePath.split('/')[-1].split('.')[4] ; # Updated for xclim
        print('Invalid grid for:',filePath)
        if 'ocean' in filePath:
            fileList = tos_fileList
        elif 'atmos' in filePath:
            fileList = tas_fileList
        for count,val in enumerate(fileList):
            if model in val:
                f = val
                fH2 = cdm.open(f)
                var2 = val.split('/')[-1].split('.')[7] ; # Always same location
                tmp2 = fH2(var2,time=slice(0,1),squeeze=1)
                # Determine longitude range and correct
                targetLats = tmp2.getLatitude()
                targetLons = tmp2.getLongitude()
                #pdb.set_trace()
                tmp.setAxis(0,tmp2.getAxis(0))
                fH2.close()
                print('Using:',val.split('/')[-1])
                continue
    # Load basinmask4 for each grid
    basinH = cdm.open('/work/durack1/Shared/obs_data/WOD13/180209_2133_WOD13_masks_0p25deg.nc')
    basinmask4 = basinH('basinmask4')
    basinLats = basinmask4.getLatitude()
    basinLons = basinmask4.getLongitude()
    if targetLons.getValue().min() >= 0. and targetLons.getValue().max() < 360.:
        basinLonsCorrect = basinLons.getValue() + 180. ; # Correct 0:360 grid
        basinLonsCorrect = cdm.createAxis(basinLonsCorrect,id='longitude')
        basinLonsCorrect.units = 'degrees_east'
        basinLonsCorrect.axis = 'X'
        basinLonsCorrect.long_name = 'longitude'
        basinLonsCorrect.standard_name = 'longitude'
        # Rearrange basinmask4 index
        basinmask4 = mv.concatenate((basinmask4[:,721:],basinmask4[:,0:721]),axis=1) ; # Rearrange
        #offset = 180.
    elif 1 == 1: # Otherwise
        basinLonsCorrect = basinLons
        #offset = 0.
    # Test for min/max
    maxTest = tmp.max()
    minTest = tmp.min()
    if maxTest == 100 or (maxTest == 100 and minTest == 0):
        # Added or test in case mask is defined correctly
        threshold = 50
    elif maxTest == 1 or (maxTest == 1 and minTest == 0):
        threshold = .5
    # Loop through grid
    targetGrid = np.ma.array(np.zeros([targetLats.shape[0],targetLons.shape[0]],dtype=np.int16), mask=True)
    # Deal with matrix lat/lons
    matDims = False
    #if targetLons.ndim > 1:
    if len(targetLons.shape) > 1:
        matDims = True
        targetGrid = np.ma.array(np.zeros([targetLats.shape[0],targetLats.shape[1]],dtype=np.int16), mask=True)
        #targetLonsTmp = targetLons.flatten().data
        #array([[1,2], [3, 4], [5, 6]]).flatten('F').reshape((3, 2), order='F')
    # Deal with 1d case
    if not matDims:
        for count1,x in enumerate(targetLons):
            if not mod(x,40): print(x)
            for count2,y in enumerate(targetLats):
                # Check sftlf values - mask land (more than 50% cells)
                #pdb.set_trace()
                if 'ocean' in filePath:
                    tmpTest = tmp(latitude=y,longitude=x)
                    if tmpTest < threshold: #or mv.is_masked(tmpTest):
                        #print(tmp(latitude=y,longitude=x).getValue()[0][0])
                        continue
                    else:
                        xInd = np.abs(x - basinLonsCorrect.getValue()).argmin()
                        yInd = np.abs(y - basinLats.getValue()).argmin()
                        #pdb.set_trace()
                        targetGrid[count2,count1] = basinmask4[int(yInd),int(xInd)]
                        targetGrid.mask[count2,count1] = basinmask4.mask[int(yInd),int(xInd)] ; # Impose basin grid mask on target
                elif 'atmos' in filePath:
                    if tmpTest > threshold:
                        #print('continue: ',tmp(latitude=y,longitude=x).getValue()[0][0])
                        continue
                    else:
                        xInd = np.abs(x - basinLonsCorrect.getValue()).argmin()
                        yInd = np.abs(y - basinLats.getValue()).argmin()
                        #pdb.set_trace()
                        targetGrid[count2,count1] = basinmask4[int(yInd),int(xInd)]
                        targetGrid.mask[count2,count1] = basinmask4.mask[int(yInd),int(xInd)] ; # Impose basin grid mask on target
    # Deal with 2d case
    elif matDims:
        for y in range(0,targetLons.shape[0]):
            if not mod(y,40): print(y)
            for x in range(0,targetLons.shape[1]):
                # Check sftof values - mask land (less than 50% cells)
                if 'ocean' in filePath:
                    if tmp[y,x] < threshold:
                        #print('continue: ',tmp[y,x],threshold)
                        continue
                    else:
                        xInd = np.abs(targetLons[y,x].getValue() - basinLonsCorrect.getValue()).argmin()
                        yInd = np.abs(targetLats[y,x].getValue() - basinLats.getValue()).argmin()
                        targetGrid[y,x] = basinmask4[int(yInd),int(xInd)] ; # Assign basin value to array
                        targetGrid.mask[y,x] = basinmask4.mask[int(yInd),int(xInd)] ; # Impose basin grid mask on target
                elif 'atmos' in filePath:
                    if tmp[y,x] > threshold:
                        #print 'continue: ',tmp[y,x],threshold
                        continue
                    else:
                        xInd = np.abs(targetLons[y,x].getValue() - basinLonsCorrect.getValue()).argmin()
                        yInd = np.abs(targetLats[y,x].getValue() - basinLats.getValue()).argmin()
                        targetGrid[y,x] = basinmask4[int(yInd),int(xInd)] ; # Assign basin value to array
                        targetGrid.mask[y,x] = basinmask4.mask[int(yInd),int(xInd)] ; # Impose basin grid mask on target
    if matDims:
        del(x,y,xInd,yInd,matDims)
    else:
        del(count1,x,count2,y,xInd,yInd,matDims)
    # Create variable
    basinmask = cdm.createVariable(targetGrid,id='basinmask4')
    #basinmask.setAxis(0,targetLats)
    #basinmask.setAxis(1,targetLons) ; # Correct from targetLons
    basinmask.setAxis(0,tmp.getAxis(0))
    basinmask.setAxis(1,tmp.getAxis(1))
    basinmask.index = '1: Atlantic Ocean; 2: Pacific Ocean; 3: Indian Ocean; 4: Arctic Ocean;'
    outFile = filePath.split('/')[-1].replace(var,'basinmask').replace('latestX.','').replace('.xml','.nc')
    # Check path
    outPath = os.path.join(localPath,'basinmask',filePath.split('/')[4],filePath.split('/')[-1].split('.')[8]) ; # Add ocn/atm to filepath
    print('outPath:',outPath)
    #pdb.set_trace()
    if not os.path.exists(outPath):
        #mkDirNoOSErr(outPath,mode=755) ; # Problems with special permissions py3
        # fix issue with weird perms on final directory
        os.makedirs(''.join([outPath,'/']),mode=755) ; # Update from os.mkdir as makedirs is recursive
    outFile = os.path.join(outPath,outFile)
    print('outfile:',outFile)
    print('outFileTrim: ',outFile.replace(localPath,''))
    if os.path.exists(outFile):
        os.remove(outFile)
    outH = cdm.open(outFile,'w')
    globalAttWrite(outH,options=None)
    # Copy across global attributes from source file - do this first, then write again so new info overwrites
    for i,key in enumerate(fH.attributes.keys()):
        setattr(outH,key,fH.attributes.get(key))
    del(i,key) ; gc.collect()
    outH.SourceFile = filePath
    outH.write(basinmask)
    outH.sync()
    # Close files
    outH.close()
    fH.close
    basinH.close()
    del(filePath,var,fH,tmp,targetLats,targetLons,basinLonsCorrect,targetGrid,
        basinmask,outFile,outH) ; gc.collect()

#%% Close all files

#%% Plot output
#x = vcs.init()
#x.meshfill(basinmask)