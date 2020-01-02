#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Nov 27 12:31:23 2019

Test issue with zeros being returned for times close to the end of the file contents.
This is a repeating issue for many NCAR.CESM2 files

For demo file, issue begins with second last timestep [1984-2013]

@author: durack1
"""

# imports
import sys
import cdat_info
import cdms2 as cdm
import numpy as np
from socket import gethostname

#%% Define function
def calcAve(var):
    print('type(var);',type(var),'; var.shape:',var.shape)

    # Start querying stat functions
    print('var.min():'.ljust(21),var.min())
    print('var.max():'.ljust(21),var.max())
    print('np.ma.mean(var.data):',np.ma.mean(var.data)) ; # Not mask aware

    # Problem transientVariable.mean() function
    print('var.mean():'.ljust(21),var.mean())
    print('-----')

#%% Load subset of variable
f = ['/p/css03/esgf_publish/CMIP6/CMIP/NCAR/CESM2/historical/r1i1p1f1/Omon/so/gn/v20190308/so_Omon_CESM2_historical_r1i1p1f1_gn_185001-201412.nc',
     '/p/user_pub/xclim/CMIP6/CMIP/historical/ocean/mon/so/CMIP6.CMIP.historical.NCAR.CESM2.r1i1p1f1.mon.so.ocean.glb-l-gn.v20190308.0000000.0.xml']
# Try arbitrary time selections
#times = [['1850','1851'],['2000','2005'],['1983','1984'],['2010','2011'],['1984','2013'],['1984','2015']]
times = [np.arange(1984,2015),[1984,2013]]
hostName = gethostname()
print('host:',hostName)
print('Python version:',sys.version)
print('cdat env:',sys.executable.split('/')[5])
print('cdat version:',cdat_info.version()[0])
print('*****')
for timeSlots in times:
    for filePath in f:
        fH = cdm.open(filePath)
        print('filePath:',filePath.split('/')[-1])
        print('Processing:',timeSlots)
        # Loop through single years
        if len(timeSlots) > 2:
            for time in timeSlots:
                start = time ; end = start+1
                print('times:',start,end)
                d1 = fH('so',time=(str(start),str(end)))
                calcAve(d1)
                del(d1)
        # Read 30-year time period
        elif len(timeSlots) == 2:
            start = timeSlots[0] ; end = timeSlots[1]
            print('times:',start,end)
            d1 = fH('so',time=(str(start),str(end)))
            calcAve(d1)
            del(d1)
        # Close file handle
        fH.close()
    print('----- -----')