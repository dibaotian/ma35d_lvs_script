#!/usr/bin/python3

import sys
import os
import glob

import subprocess
import json

# ////////////////////////////////////////////////////////////////////////////
# Get info about MA35D load
# -------------------------------------
# Usage:
#   print_ma35d_load
# ////////////////////////////////////////////////////////////////////////////
# ============================================================================
# ToDo
# ============================================================================
#   o) Check that the bash commands are correctly executed - no errors
# ============================================================================



# =====================================================
# Collect info about each video file and store it
# in the Video_Files_Data dictionary
# =====================================================
Video_Files_Data = {}

# ------------------------------------------------------
# List of properties we will collect via ffmpeg command
# ------------------------------------------------------
List_Of_Properties_To_Collect = ['instanceName', 'numChanInuse', 'usedLoad', 'reservedLoad']


# ---------------------------------------------------------------------
# List of properties which will be printed in the table
# ---------------------------------------------------------------------
List_Of_Video_Properties_To_Print   = ['Device_ID', 'instanceName', 'numChanInuse', 'usedLoad', 'reservedLoad', 'Utilization(%)' ]

# -------------------------------------------------------
# Compose xrmadm command to get info about U30 load
# Run xrmadm command
# -------------------------------------------------------
xrmadm_cmd = '/opt/amd/ma35/bin/xrmadm /opt/amd/ma35/scripts/list_cmd.json'
json_data = json.loads(subprocess.check_output(xrmadm_cmd, shell=True))

#print('DEBUG:', json_data)


# -------------------------------------------------------
# Get Nb of Devices in a system
# -------------------------------------------------------
Device_Data = json_data['response']['data']
NoF_Devices = int(Device_Data['deviceNumber'])

if NoF_Devices == 0:
    print ('\nERROR: No MA35D devices found in a system\n')
    sys.exit()

#print('DEBUG:', NoF_Devices)

# -------------------------------------------------------
# Print Table Header
# -------------------------------------------------------
Line_Width=111
print()
print('='*Line_Width)
print('MA35D Device Load')
print('='*Line_Width)
#print('{:10} {:20} {:15} {:15} {:15} {:15} {}'.format('Device_ID', 'cuName', 'numChanInuse', 'usedLoad', 'reservedLoad', '', 'Utilization(%)'))
print('{:10} {:20} {:15} {:15} {:15} {:15} {}'.format('Device_ID', 'kernelAlias', 'numChanInuse', 'usedLoad', 'reservedLoad', '', 'Utilization(%)'))
print('-'*Line_Width)

# -------------------------------------------------------
# Scan all devices / Scan 6 CUs
# -------------------------------------------------------
for device_idx in range(int(NoF_Devices)):
    device_id = 'device_'+str(device_idx)
    Current_Device_Data = Device_Data[device_id]

    #print('DEBUG:', Current_Device_Data)
    #sys.exit()

    # --------------------------------
    # Check if the device is used
    # --------------------------------
    numChanInuse_Total = 0
    usedLoad_Total     = 0
    reservedLoad_Total = 0

    for cu_idx in range(8):
        cu_id = 'cu_'+str(cu_idx)
        Current_CU_Data = Current_Device_Data[cu_id]
        #print(Current_CU_Data)

        numChanInuse_Total = numChanInuse_Total +  int(Current_CU_Data['numChanInuse '])
        usedLoad_Total     = usedLoad_Total     + int((Current_CU_Data['usedLoad     ']).split('of')[0])
        reservedLoad_Total = reservedLoad_Total + int((Current_CU_Data['reservedLoad ']).split('of')[0])


    if (int(numChanInuse_Total) ==0) and (int(usedLoad_Total) == 0) and (int(reservedLoad_Total) == 0):
        print('{:10} {:20}'.format(device_id, 'Not Used'))
    else:
        for cu_idx in range(8):
            cu_id = 'cu_'+str(cu_idx)
            #print('DEBUG:', cu_id)
            Current_CU_Data = Current_Device_Data[cu_id]
            #print('DEBUG:', Current_CU_Data)


            #cuName         =  str(Current_CU_Data['instanceName '])
            cuName         =  str(Current_CU_Data['kernelAlias  '])
            numChanInuse   =  str(Current_CU_Data['numChanInuse '])
            usedLoad       = str((Current_CU_Data['usedLoad     ']).split('of')[0])
            usedLoad_total = str((Current_CU_Data['usedLoad     ']).split('of')[1])
            reservedLoad   = str((Current_CU_Data['reservedLoad ']).split('of')[0])
            
            utilization    = int(usedLoad) / int(usedLoad_total) * 100.0
            if (cuName != 'VCU_1'):
                print('{:10} {:20} {:15} {:15} {:15} {:15} {:>6.1f}'.format(device_id, cuName, numChanInuse, usedLoad, reservedLoad, 'of '+usedLoad_total, utilization))

    print('-'*Line_Width)



