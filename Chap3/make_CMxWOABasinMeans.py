#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Dec 17 16:01:57 2019

Paul J. Durack 17th December 2019

This script builds thetao/so basin zonal means using climatologies and masks

@author: durack1
"""

import glob,os,vcs
import cdms2 as cdm

#%% Define paths
workDir = '/work/durack1/Shared/190311_AR6/Chap3'
varList = []
for mipEra in ['CMIP5','CMIP6']:

# Get list of model-gridded files
    vars()['_'.join(['modList',mipEra])] = glob.glob(os.path.join(workDir,'ncs',mipEra,'historical','modGrid','*-clim.nc'))
    varList.append('_'.join(['modList',mipEra]))
# Get list of WOA-gridded files
    vars()['_'.join(['woaList',mipEra])]  = glob.glob(os.path.join(workDir,'ncs',mipEra,'historical','woaGrid','*-woaClim.nc'))
    varList.append('_'.join(['woaList',mipEra]))
# Get a list of basinmask files
    vars()['_'.join(['basinMask',mipEra])]  = glob.glob(os.path.join(workDir,'basinmask',mipEra,'ocean','*.nc'))
    varList.append('_'.join(['basinMask',mipEra]))

#%% Sort all lists
for var in varList:
    eval(var).sort()

#%% Collapse back to WOA-only grids to get something working
for count,filePath in enumerate(woaList_CMIP6):
    print('{:03d}'.format(count),filePath)
    fH = cdm.open(filePath)
    if 'thetao' in filePath:
        varName = 'thetao_mean_WOAGrid'
    elif 'so' in filePath:
        varName = 'so_mean_WOAGrid'

    fH = cdm.open(filePath)
    var = fH(varName)
    print('var.shape:',var.shape)
    varSlice = var[0,:,:,int(var.shape[3]/2)] ; # Find middle longitude value
    x = vcs.init(bg=True)
    x.plot(varSlice)
    x.png(os.path.join('png',filePath.split('/')[-1].replace('.nc','.png')))