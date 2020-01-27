#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 12 13:28:32 2019

Paul J. Durack 12th March 2019

This script builds thetao/so climatology files use in bias calculations

PJD 12 Mar 2019     - Started
PJD 13 Mar 2019     - Updated to deal with new durolib distrib
PJD 13 Mar 2019     - Updated read call to year+1
PJD 14 Mar 2019     - Added timing to see how reads are performing on /p/css03
PJD 15 Mar 2019     - Added logging of times
PJD 21 Mar 2019     - Added pydbg
PJD  8 Aug 2019     - Updated to stable xml paths
PJD 10 Oct 2019     - Updated with climlib
PJD  5 Nov 2019     - Updated to deal with calendar wrangling
PJD  6 Nov 2019     - Added climInterp3.astype('float32') to deal with weird errors
PJD  6 Nov 2019     - Dealt with weird timeAx type issue (was reltime not float/double)
PJD  6 Nov 2019     - Updated to log and deal with outputs into separate subdirs
PJD  6 Nov 2019     - Added create output subdir if it doesn't exist
PJD  6 Nov 2019     - Corrected issues with os calls makedirS and existS
PJD  6 Nov 2019     - Updated to remove duplicate file and dir names
PJD  7 Nov 2019     - Updated to deal with existing destination subdirs
PJD  7 Nov 2019     - Updated to deal with files not spanning temporal range
PJD  7 Nov 2019     - Added experimentId to path - anticipating multiple experiments
PJD  8 Nov 2019     - New BCC error to deal with #29+99=128
PJD 12 Nov 2019     - Problem with BCC grid, defer just skip for now (#128; also
                      tested 129 and 130 to ensure this is a model and not file specific)
0 /p/user_pub/xclim/CMIP5/CMIP/historical/ocean/mon/so/CMIP5.CMIP.historical.BCC.bcc-csm1-1.r1i1p1.mon.so.ocean.glb-z1-gu.v20130329.0000000.0.xml
Mount path: /p/css03/cmip5_css01/data/cmip5/output1/BCC/bcc-csm1-1/historical/mon/ocean/Omon/r1i1p1/v20130329/so/
dH shape: (1956, 40, 232, 360)
s.shape: (102, 180, 360)
Time: 105754
starts : 1975-1-16 12:0:0.0
ends   : 2005-12-16 12:0:0.0
Time: 110442 cdu start
Time: 110557 cdu end
Traceback (most recent call last):
  File "make_CMxWOAClims.py", line 230, in <module>
    print('Time:',datetime.datetime.now().strftime('%H%M%S'),'cdu end')
  File "/export/durack1/anaconda3/envs/cdat82MesaPy3/lib/python3.7/site-packages/cdms2/avariable.py", line 1228, in regrid
    getBoundList(_getCoordList(self.getGrid())))
  File "/export/durack1/anaconda3/envs/cdat82MesaPy3/lib/python3.7/site-packages/cdms2/mvCdmsRegrid.py", line 240, in getBoundList
    cornerC = _buildBounds(c.getBounds()[:])
TypeError: 'NoneType' object is not subscriptable


PJD 13 Nov 2019     - New AWI error #148
148 /p/user_pub/xclim/CMIP6/CMIP/historical/ocean/mon/so/CMIP6.CMIP.historical.AWI.AWI-CM-1-1-MR.r1i1p1f1.mon.so.ocean.glb-l-gn.v20181218.0000000.0.xml
Mount path: /p/css03/esgf_publish/CMIP6/CMIP/AWI/AWI-CM-1-1-MR/historical/r1i1p1f1/Omon/so/gn/v20181218/
dH shape: (1980, 46, 830305)
s.shape: (102, 180, 360)
Time: 054445
starts : 1984-1-16 12:0:0.0
ends   : 2014-12-16 12:0:0.0
Time: 055127 cdu start
Time: 061246 cdu end
Traceback (most recent call last):
  File "make_CMxWOAClims.py", line 210, in <module>
    climInterp = climLvl.regrid(woaGrid,regridTool='ESMF',regridMethod='linear')
  File "/export/durack1/anaconda3/envs/cdat82MesaPy3/lib/python3.7/site-packages/cdms2/avariable.py", line 1348, in regrid
    **keywords)
  File "/export/durack1/anaconda3/envs/cdat82MesaPy3/lib/python3.7/site-packages/cdms2/mvCdmsRegrid.py", line 441, in __init__
    srcCoords = _getCoordList(srcGrid)
  File "/export/durack1/anaconda3/envs/cdat82MesaPy3/lib/python3.7/site-packages/cdms2/mvCdmsRegrid.py", line 280, in _getCoordList
    cgrid = grid.toCurveGrid()
AttributeError: 'TransientGenericGrid' object has no attribute 'toCurveGrid'


PJD 13 Nov 2019     - Same problem with BCC CMIP6 contributions
8 /p/user_pub/xclim/CMIP6/CMIP/historical/ocean/mon/thetao/CMIP6.CMIP.historical.BCC.BCC-ESM1.r1i1p1f1.mon.thetao.ocean.glb-l-gn.v20181129.0000000.0.xml
Mount path: /p/css03/esgf_publish/CMIP6/CMIP/BCC/BCC-ESM1/historical/r1i1p1f1/Omon/thetao/gn/v20181129/
dH shape: (1980, 40, 232, 360)
s.shape: (102, 180, 360)
Time: 135324
starts : 1984-1-16 12:0:0.0
ends   : 2014-12-16 12:0:0.0
Time: 135452 cdu start
Time: 135612 cdu end
Traceback (most recent call last):
  File "make_CMxWOAClims.py", line 279, in <module>
    climInterp = climLvl.regrid(woaGrid,regridTool='ESMF',regridMethod='linear')
  File "/export/durack1/anaconda3/envs/cdat82MesaPy3/lib/python3.7/site-packages/cdms2/avariable.py", line 1228, in regrid
    getBoundList(_getCoordList(self.getGrid())))
  File "/export/durack1/anaconda3/envs/cdat82MesaPy3/lib/python3.7/site-packages/cdms2/mvCdmsRegrid.py", line 240, in getBoundList
    cornerC = _buildBounds(c.getBounds()[:])
TypeError: 'NoneType' object is not subscriptable

PJD 13 Nov 2019     - Added cdms2 file compression options
PJD 14 Nov 2019     - Added bcc-csm1-1-m to CMIP5 exclusion list
PJD 14 Nov 2019     - Added end AND start year checking to deal with short times in NorCPM1.r17i1p1f1.mon.so (207) and NorCPM1.r23i1p1f1.mon.thetao (210)
PJD 26 Nov 2019     - Missing value error in regridded/woagrid output - pr.rgrd needs additional arguments
PJD 26 Nov 2019     - Added step by step object min/mean/max validation to see how interpolation is changing values
PJD 27 Nov 2019     - Update horizontal interp to conservative after talking with Pete G
PJD 27 Nov 2019     - Added fixVarUnits to correct NCAR wonky units (also issue with K vs degC) in CMIP6.CMIP.historical.NCAR.CESM2.r1i1p1f1.mon.so.ocean.glb-l-gn.v20190308 (16)
PJD 27 Nov 2019     - Workaround added for the cdms2/transientVariable d1.mean()/median() functions
PJD 28 Nov 2019     - Added test for valid/online data as EC-Earth3-Veg.historical.r2i1p1f1.mon.so (104) was moved from scratch
PJD 29 Nov 2019     - Added test code
PJD 29 Nov 2019     - Added test for MIROC-ES2L.historical.r1i1p1f2.so.gn.v20190823 (184)
PJD 29 Nov 2019     - Added zero-value tests (CESM2, MIROC-ES2L) for file skipping
PJD 29 Nov 2019     - Added durolib fix (remove var.mean() queries) for FGOALS-f3-L.historical.r1i1p1f1.thetao.gn.v20190822 (108)
PJD  3 Dec 2019     - Added test for CNRM-CM6-1-HR.historical.r1i1p1f2.mon.so.gn.v20191021 (46) - couldn't reproduce, memory issue
PJD 18 Dec 2019     - Added mask wash for climInterp3 from 1e+20 to 1e+10 (1e+6 masked everything); fixed historical.CCCma.CanESM5.r1i1p1f1.mon.so.ocean.glb-l-gn.v20190306 (66)
PJD 18 Dec 2019     - Toggle between ESMF conservative and linear to see what is happening with 2D interp
PJD 29 Dec 2019     - Updated zero matrix text for floats (was ints)
PJD 29 Dec 2019     - Need to exclude CNRM-CM6-1-HR from direct analysis, using ~360Gb
PJD 29 Dec 2019     - Ongoing issues with CESM2* data; zero-valued arrays being loaded for some realizations; vertical interp issues for others
                      NCAR.CESM2.historical.r10i1p1f1.mon.so.ocean.glb-l-gn.v20190313 (14) - vert issues
                      NCAR.CESM2.historical.r1i1p1f1.mon.so.ocean.glb-l-gn.v20190308 (16) - zero arrays
PJD 22 Jan 2020     - Testing for missing CMIP5 data (update call to trimModelList)
                    - TODO: Update durolib to work with py3
                    - TODO: Generate basin masks for each input

@author: durack1
"""

#%% Imports
from __future__ import print_function ; # Make py2 backward compatible
import argparse,copy,datetime,gc,glob,os,regrid2,sys,time,pdb
#import pdb,sys,warnings
import cdms2 as cdm
import cdtime as cdt
import cdutil as cdu
import MV2 as mv
import numpy as np
os.sys.path.insert(0,'/export/durack1/git/durolib/durolib')
from durolib import fixVarUnits,globalAttWrite,writeToLog #,trimModelList
os.sys.path.insert(0,'/export/durack1/git/climlib/climlib')
#import climlib
from wrangle import trimModelList ; # climlib
from socket import gethostname

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
parser.add_argument('variableId',help='e.g. tas, tos, pr, sos etc')
parser.add_argument('-r','--realm',help='ocean assumed, specify if other',default='ocean')
parser.add_argument('-f','--frequency',help='monthly assumed, specify if other',default='mon')
args = parser.parse_args()

#%% Error trapping
#warnings.simplefilter('error')
# https://github.com/numpy/numpy/issues/11411#issuecomment-445507078

#%% Get arguments
if args.mipEra in ['CMIP5','CMIP6']:
    mipEra = args.mipEra
    print('mipEra:',mipEra)
if args.activityId in ['CMIP','ScenarioMIP']:
    activityId = args.activityId
    print('activityId:',activityId)
if args.experimentId in ['historical']:
    experimentId = args.experimentId
    print('experimentId:',experimentId)
if args.realm in ['ocean']:
    realm = args.realm
    print('realm:',realm)
if args.frequency in ['mon']:
    frequency = args.frequency
    print('frequency:',frequency)
if args.variableId in ['so','thetao']:
    variableId = args.variableId
    print('variableId:',variableId)
# Test for entries
varsToTest = ['mipEra','activityId','experimentId','realm','frequency','variableId']
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
realm = 'ocean'
frequency = 'mon'
variableId = 'so'; #'thetao' ;#'so'
'''
#%% Set current dirs
workDir = '/work/durack1/Shared/190311_AR6/Chap3'
xmlPath = '/p/user_pub/xclim/' ; #'/data_crunchy_oceanonly/crunchy_work/cmip-dyn'

#%% Generate log file
timeNow = datetime.datetime.now();
timeFormat = timeNow.strftime("%y%m%dT%H%M%S")
logFile = os.path.join(workDir,'_'.join([timeFormat,'CMxWOA',mipEra,activityId,experimentId,variableId,'logs.txt']))
textToWrite = ' '.join(['TIME:',timeFormat])
writeToLog(logFile,textToWrite)
pypid = str(os.getpid()) ; # Returns calling python instance, so master also see os.getppid() - Parent
writeToLog(logFile,' '.join(['MASTER PID:',pypid]))
writeToLog(logFile,' '.join(['UV-CDAT:',sys.executable]))
host_name = gethostname()
print(' '.join(['HOSTNAME:',host_name]))
writeToLog(logFile,' '.join(['HOSTNAME:',host_name]))
print('----------')
writeToLog(logFile,'----------')

#%% Preallocate lists and fill
fileLists = []
#for mip in mipEra:
mip = mipEra
#for var in variableId:
var = variableId
#print(var)
searchPath = os.path.join(xmlPath,mip,activityId,experimentId,realm,frequency,var,'*.xml')
print('searchPath:',searchPath)
writeToLog(logFile,' '.join(['searchPath:',searchPath]))
fileList = glob.glob(searchPath) ; fileList.sort()
print(var,' len(fileList):     ',len(fileList))
writeToLog(logFile,''.join([var,' len(fileList):     ',str(len(fileList))]))
fileListTrim = trimModelList(fileList, criteria=['tpoints', 'cdate', 'ver']) ; #'publish',
print(var,' len(fileListTrim): ',len(fileListTrim))
writeToLog(logFile,''.join([var,' len(fileListTrim): ',str(len(fileListTrim))]))
print('_'.join([mip,experimentId,var]))
writeToLog(logFile,'_'.join([mip,experimentId,var]))
varName = '_'.join([mip,experimentId,var])
vars()[varName] = fileListTrim
fileLists.extend([varName])
del(mip,var,searchPath,fileList,fileListTrim,varName) ; gc.collect()

#%% Generate climatology periods
climPeriod = ([1975,2006],[1984,2015])

#%% Deal with input lists
for count,lst in enumerate(fileLists):
    if count == 0:
        fileList = copy.deepcopy(eval(lst))
    else:
        fileList.extend(eval(lst))
del(count,fileLists)

#%% Preload WOA18 grids
#warnings.simplefilter('error')
woa         = cdm.open('/work/durack1/Shared/obs_data/WOD18/190312/woa18_decav_s00_01.nc')
s           = woa('s_oa')
print('Start read wod18')
print('type(s):',type(s))
s           = s[(0,)]
print('End read wod18')
woaLvls     = s.getLevel()
woaGrid     = s.getGrid() ; # Get WOA target grid
woaLat      = s.getLatitude()
woaLon      = s.getLongitude()
woa.close()

#%% Loop through files
for count,filePath in enumerate(fileList):
    print(count,filePath)
    # Add AWI, BCC kludge - have to fix grid issue - *** TypeError: 'NoneType' object is not subscriptable
    if any(x in filePath for x in ['.AWI-CM-1-1-MR.','.bcc-csm1-1.','.bcc-csm1-1-m.','.BCC-CSM2-MR.','.BCC-ESM1.']):
        strTxt = ' '.join([str(count),'** Known grid issue with:',filePath.split('/')[-1],'skipping..**'])
        print(strTxt)
        writeToLog(logFile,strTxt)
        continue
    writeToLog(logFile,' '.join([str(count),filePath]))
    var = filePath.split('/')[-2]
    mipEra = filePath.split('/')[4]
    # Generate climatological period
    if mipEra == 'CMIP5':
        startYr = climPeriod[0][0]
        startYrCt = cdt.comptime(startYr)
        endYr = climPeriod[0][1]
        endYrCt   = cdt.comptime(endYr)
    elif mipEra == 'CMIP6':
        startYr = climPeriod[1][0]
        startYrCt = cdt.comptime(startYr)
        endYr = climPeriod[1][1]
        endYrCt   = cdt.comptime(endYr)
    #print('open file')
    fH = cdm.open(filePath)
    mntPathStr = ' '.join(['Mount path:',fH.directory])
    print(mntPathStr)
    writeToLog(logFile,mntPathStr)
    # Test that path exists
    if not os.path.exists(fH.directory):
        prStr = 'Data path no longer available'
        print(prStr)
        writeToLog(logFile,prStr)
        continue
    startTime = time.time()
    #print('start data read')
    dH = fH[var]
    #print('dH.max:',dH.max())
    #print('dH.min:',dH.min())
    #print('dH loaded')
    #pdb.set_trace()
    print('dH shape:',dH.shape)
    writeToLog(logFile,' '.join(['dH shape:',str(dH.shape)]))
    # Specify levels for per-level read/write
    levs = dH.getLevel()
    # Preallocate WOA and model grids
    print('s.shape (WOA):',s.shape)
    print('Time:',datetime.datetime.now().strftime('%H%M%S'))
#    climInterp = np.ma.zeros([s.shape[0],s.shape[1],s.shape[2]])
#    clim = np.ma.zeros([dH.shape[1],dH.shape[2],dH.shape[3]])
# Loop over levels
#    for lvl in range(len(levs)):
#        print('lvl:',lvl)
##        if lvl % 10 == 0:
##            print('lvl: %02d' % lvl)
##        try:
#        d = fH(var,time=(startYrCt,endYrCt,'con'),lev=slice(lvl,lvl+1))
#        times = d.getTime()
#        print('starts :',times.asComponentTime()[0])
#        print('ends   :',times.asComponentTime()[-1])
#        climLvl = cdu.YEAR.climatology(d)
#        clim[lvl,] = climLvl
#        climInterp[lvl,] = climLvl.regrid(woaGrid,regridTool='ESMF',regridMethod='linear')
#        del(d,climLvl) ; gc.collect()

    # Test valid dates
    timeCheck = dH.getTime()
    #pdb.set_trace()
    startYrChk = timeCheck.asComponentTime()[0].year
    endYrChk = timeCheck.asComponentTime()[-1].year
    # Test
    if (endYrChk < endYrCt.year-1) or (startYrChk > startYrCt.year):
        # Skip file and go to next, note 2006-1 to give 2005 coverage
        reportStr = ''.join(['*****\n',filePath.split('/')[-1],
                              ' does not cover temporal range; target: ',
                              str(endYrCt.year-1),' vs file: ',str(endYrChk),
                              ' skipping to next file..\n','*****',])
        print(reportStr)
        writeToLog(logFile,reportStr)
        continue

    # No level looping
    print('var:',var)
    print('startYrCt:',startYrCt)
    print('endYrCt:  ',endYrCt)
    d1 = fH(var,time=(startYrCt,endYrCt,'con'))
    '''
    print('d1.max:',d1.max())
    print('d1.min:',d1.min())
    d2 = fH(var,time=('1984','2015','con')) ; # Outside lim
    print('d2.max:',d2.max())
    print('d2.min:',d2.min())
    d3 = fH(var,time=('1984','2015')) ; # Outside lim
    print('d3.max:',d3.max())
    print('d3.min:',d3.min())
    d4 = fH(var,time=('1850','1851')) ; # Within lim
    print('d4.max:',d4.max())
    print('d4.min:',d4.min())
    d5 = fH(var,time=('1984','2014')) ; # On lim
    print('d5.max:',d5.max())
    print('d5.min:',d5.min())
    d6 = fH(var,time=('1984','2013')) ; # Within lim
    print('d6.max:',d6.max())
    print('d6.min:',d6.min())
    pdb.set_trace()
    '''
    # Add test for 0-valued arrays
    if d1.max == 0. and d1.min == 0.:
        # Skip file and go to next, note 2006-1 to give 2005 coverage
        reportStr = ''.join(['*****\n',filePath.split('/')[-1],
                              ' has zero-valued arrays,',
                              ' skipping to next file..\n','*****',])
        print(reportStr)
        writeToLog(logFile,reportStr)
        continue
    # Validate variable axes
    #for i in range(len(d1.shape)):
    #    ax = d1.getAxis(i)
    #    print(ax.id,len(ax))
    #pdb.set_trace()
    d1,varFixed = fixVarUnits(d1,var,report=True,logFile=logFile)
    #print('d1.max():',d1.max().max().max(),'d1.min():',d1.min().min().min()) ; Moved below for direct comparison
    #print('d1 loaded')
    #pdb.set_trace()
    times = d1.getTime()
    print('starts :',times.asComponentTime()[0])
    print('ends   :',times.asComponentTime()[-1])
    print('Time:',datetime.datetime.now().strftime('%H%M%S'),'cdu start')
    climLvl = cdu.YEAR.climatology(d1)
    #print('climLvl created')
    #pdb.set_trace()
    print('Time:',datetime.datetime.now().strftime('%H%M%S'),'cdu end')
    clim = climLvl
    #pdb.set_trace()
    climInterp = climLvl.regrid(woaGrid,regridTool='ESMF',regridMethod='linear')
    #climInterp = climLvl.regrid(woaGrid,regridTool='ESMF',regridMethod='conservative') ; # Chat to Pete 191127
    #print('climInterp created')
    precision = 8.3 ; # Updated to deal with Kelvin 300.xx
    d1Max = np.max(d1) #d1.max().max().max()
    d1Mean = np.mean(d1.data) #1 #np.mean(d1) #np.mean(d1.data)
    d1Median = np.median(d1.data) #1 #np.median(d1) #np.median(d1.data)
    d1Min = np.min(d1) #1.min().min().min()
    d1Str = ''.join(['d1.max()'.ljust(16),':',
                     '{:{}f}'.format(d1Max,precision),
                     ' mean:','{:{}f}'.format(d1Mean,precision),
                     ' median:','{:{}f}'.format(d1Median,precision), # This method is oblivious to the mask/missing values
                     ' min:','{:{}f}'.format(d1Min,precision)])
    print(d1Str)
    writeToLog(logFile,d1Str)
    climInterpMax = np.max(climInterp) #climInterp.max().max().max()
    climInterpMean = np.mean(climInterp.data)
    climInterpMedian = np.median(climInterp.data)
    climInterpMin = np.min(climInterp) #climInterp.min().min().min()
    climInterpStr = ''.join(['climInterp.max()'.ljust(16),':',
                             '{:{}f}'.format(climInterpMax,precision),
                             ' mean:','{:{}f}'.format(climInterpMean,precision),
                             ' median:','{:{}f}'.format(climInterpMedian,precision),
                             ' min:','{:{}f}'.format(climInterpMin,precision)])
    print(climInterpStr)
    writeToLog(logFile,climInterpStr)
    del(d1,climLvl) ; gc.collect()

    # Regrid vertically
    pr = regrid2.pressure.PressureRegridder(levs,woaLvls)
    #climInterp2 = pr(climInterp)
    #climInterp2 = pr.rgrd(climInterp,None,None) ; # This interpolation is currently not missing data aware
    climInterp2 = pr.rgrd(climInterp,climInterp.missing,'equal') ; # By default output missing value will be missingValueIn
    # rgrd(dataIn,missingValueIn,missingMatch,logYes='yes',positionIn=None,missingValueOut=None)
    # https://github.com/CDAT/cdms/blob/master/regrid2/Lib/pressure.py#L150-L222
    #pdb.set_trace()
    climInterp2Max = np.max(climInterp2)
    climInterp2Mean = np.mean(climInterp2)
    climInterp2Median = np.median(climInterp2)
    climInterp2Min = np.min(climInterp2)
    climInterp2Str = ''.join(['climInterp2.max():',
                              '{:{}f}'.format(climInterp2Max,precision),
                              ' mean:','{:{}f}'.format(climInterp2Mean,precision),
                              ' median:','{:{}f}'.format(climInterp2Median,precision),
                              ' min:','{:{}f}'.format(climInterp2Min,precision)])
    print(climInterp2Str)
    writeToLog(logFile,climInterp2Str)
    #print('climInterp2 created')
    #pdb.set_trace()
    # Mask invalid datapoints
    climInterp3 = mv.masked_where(mv.equal(climInterp2,1e+20),climInterp2)
    climInterp3 = mv.masked_where(mv.greater(climInterp3,1e+10),climInterp3) ; # Add great to catch fringe values, switched from 1e+20 to 1e+10
    print('climInterp3.missing:',climInterp3.missing)
    #climInterp3.setMissing(1e+20) ; # Specifically assign missing value
    #print('climInterp3 created')
    #pdb.set_trace()
    '''
    import matplotlib.pyplot as plt
    climSlice = clim[0,0,:,:] ; plt.figure(1) ; plt.contourf(clim.getLongitude().data,clim.getLatitude().data,climSlice,20) ; #clim
    plt.show()
    climInterpSlice = climInterp[0,0,:,:] ; plt.figure(2) ; plt.contourf(climInterp.getLongitude().getData(),climInterp.getLatitude().getData(),climInterpSlice,20) ; #climInterp
    plt.show()
    #climInterp2Slice = climInterp2[0,0,:,:] ; plt.figure(3) ; plt.contourf(climInterp.getLongitude().getData(),climInterp.getLatitude().getData(),climInterp2Slice,20) ; #climInterp2
    #plt.show()
    climInterp3Slice = climInterp3[0,0,:,:] ; plt.figure(4) ; plt.contourf(climInterp.getLongitude().getData(),climInterp.getLatitude().getData(),climInterp3Slice,20) ; #climInterp3
    plt.show()
    '''
    #climInterp3 = mv.masked_where(mv.greater(climInterp2,100),climInterp2) ; # Fudge for deep BNU fields
    climInterp3.id = "".join([var,'_mean_WOAGrid'])
    climInterp3Max = np.max(climInterp3)
    climInterp3Mean = np.mean(climInterp3)
    #climInterp3Median = np.median(climInterp3)
    climInterp3Median = np.median(climInterp3.data) ; # Fix for MIROC-ES2L.historical.r1i1p1f2.so.gn.v20190823 (184)
    climInterp3Min = np.min(climInterp3)
    climInterp3Str = ''.join(['climInterp3.max():',
                              '{:{}f}'.format(climInterp3Max,precision),
                              ' mean:','{:{}f}'.format(climInterp3Mean,precision),
                              ' median:','{:{}f}'.format(climInterp3Median,precision),
                              ' min:','{:{}f}'.format(climInterp3Min,precision)])
    print(climInterp3Str)
    writeToLog(logFile,climInterp3Str)

    # Redress WOA grid
    #pdb.set_trace()
    print('climInterp3.shape:',climInterp3.shape)
    #timeAx = cdm.createAxis(np.mean([startYrCt.absvalue,endYrCt.absvalue]),[startYrCt,endYrCt],id='time')
    # TypeError: len() of unsized object
    startYrCtYear = startYrCt.year
    startYrCtMonth = startYrCt.month
    startYrCtDay = startYrCt.day
    #pdb.set_trace()
    calStr = ' '.join(['days since','-'.join([str(startYrCtYear),str(startYrCtMonth),str(startYrCtDay)])])
    timeMean = np.mean([startYrCt.torel(calStr).value,endYrCt.torel(calStr).value])
    #timeMean = cdt.relativetime(timeMean,calStr)
    timeBounds = np.array([startYrCt.torel(calStr).value,endYrCt.torel(calStr).value])
    timeAx = cdm.createAxis((timeMean,),bounds=timeBounds,id='time')
    timeAx.units = calStr ; # Assign units to ndarray type NOT reltime type
    #print(timeAx)
    #pdb.set_trace()
    climInterp3.setAxis(0,timeAx)
    climInterp3.setAxis(1,woaLvls)
    climInterp3.setAxis(2,woaLat)
    climInterp3.setAxis(3,woaLon)

    # Write out data
    modId = '.'.join(['.'.join(filePath.split('/')[-1].split('.')[:-3]),'-'.join([str(startYr),str(endYr-1),'clim']),'nc'])
    outFMod = os.path.join(workDir,'ncs',mipEra,experimentId,'modGrid')
    outFModId = os.path.join(outFMod,modId)
    woaId = '.'.join(['.'.join(filePath.split('/')[-1].split('.')[:-3]),'-'.join([str(startYr),str(endYr-1),'woaClim']),'nc'])
    outFWoa = os.path.join(workDir,'ncs',mipEra,experimentId,'woaGrid')
    outFWoaId = os.path.join(outFWoa,woaId)
    #pdb.set_trace()

    # Write out data
    # Check file exists
    #pdb.set_trace()
    if os.path.exists(outFModId):
        print('** File exists.. removing **')
        os.remove(outFModId)
    if not os.path.exists(outFMod):
        os.makedirs(outFMod)
    modIdH = cdm.open(outFModId,'w')
    # Copy across global attributes from source file - do this first, then write again so new info overwrites
    for i,key in enumerate(fH.attributes.keys()):
        setattr(modIdH,key,fH.attributes.get(key))
    del(i,key) ; gc.collect()
    globalAttWrite(modIdH,options=None)
    modIdH.climStart = str(times.asComponentTime()[0])
    modIdH.climEnd = str(times.asComponentTime()[-1])
    modIdH.write(clim.astype('float32'))
    modIdH.close()
    # Check file exists
    if os.path.exists(outFWoaId):
        print('** File exists.. removing **')
        os.remove(outFWoaId)
    if not os.path.exists(outFWoa):
        os.makedirs(outFWoa)
    woaIdH = cdm.open(outFWoaId,'w')
    # Copy across global attributes from source file - do this first, then write again so new info overwrites
    for i,key in enumerate(fH.attributes.keys()):
        setattr(woaIdH,key,fH.attributes.get(key))
    del(i,key) ; gc.collect()
    globalAttWrite(woaIdH,options=None)
    woaIdH.climStart = str(times.asComponentTime()[0])
    woaIdH.climEnd = str(times.asComponentTime()[-1])
    #pdb.set_trace()
    woaIdH.write(climInterp3.astype('float32'))
    woaIdH.close()
    fH.close()

    #print('end data read')
    endTime = time.time()
    print('Time taken (secs):','{:.2f}'.format(endTime-startTime))
    writeToLog(logFile,' '.join(['Time taken (secs):','{:.2f}'.format(endTime-startTime)]))
    print('----------')
    writeToLog(logFile,'----------')