#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Jun 16 23:06:02 2020

@author: cferreira
"""

import pandas
import numpy as np
import glob
import pickle

csv_dir = "./2019_Martim_EyeTracking_DataAnalysis/csv_data/"
cts_dir = "/home/cferreira/mount/Datasets/Lung/LN-DETECTOR Database/"
csv_time = pandas.read_csv(csv_dir + 'time_total_valid_time.csv')
mean_valid_time = np.mean(csv_time.ValidTime)
std_valid_time = np.std(csv_time.ValidTime)

valid_time = csv_time.ValidTime
LNDid = csv_time.LNDid
tam_csv_time = len(csv_time)
slices2ct = np.zeros([tam_csv_time,4])

for i in range(tam_csv_time):
    ct = str(csv_time.LNDid[i])
    if len(ct) == 1:
        dir2find = cts_dir + "LNDETECTOR-000" + ct + "/"
    elif (len(ct)) == 2:
        dir2find = cts_dir + "LNDETECTOR-00" + ct + "/"
    elif (len(ct)) == 3:
        dir2find = cts_dir + "LNDETECTOR-0" + ct + "/"
    tam_slice = len(glob.glob(dir2find + '/*')) - len(glob.glob(dir2find + '/*.xml'))
    slices2ct[i,0] = csv_time.LNDid[i]
    slices2ct[i,1] = csv_time.Radid[i]
    slices2ct[i,2] = tam_slice
    slices2ct[i,3] = csv_time.ValidTime[i] / tam_slice
    
mean_slice_time = np.mean(slices2ct[:,3])
std_slice_time = np.std(slices2ct[:,3])

csv_time_sectors = pandas.read_csv(csv_dir + 'segments_time.csv')
time_inside_lung = np.zeros([tam_csv_time,3])
time_inside_sectors = np.zeros([2,46])

right_idx = range(1,24)
left_idx = range(24,47)

for j in range(23):
    df1 = csv_time_sectors[str(right_idx[j])]
    df2 = csv_time_sectors[str(left_idx[j])]
    time_inside_sectors[0,j] = np.mean(df1)
    time_inside_sectors[1,j] = np.std(df1)
    time_inside_sectors[0,j+23] = np.mean(df2)
    time_inside_sectors[1,j+23] = np.std(df2)
    for i in range(tam_csv_time):
        time_inside_lung[i,0] += df1[i]
        time_inside_lung[i,1] += df2[i]
        
time_inside_sectors = np.transpose(time_inside_sectors)
time_inside_lung[:,2] += time_inside_lung[:,0] + time_inside_lung[:,1]

mean_valid_time_lung_right = np.mean(time_inside_lung[:,0])
std_valid_time_lung_right = np.std(time_inside_lung[:,0])

mean_valid_time_lung_left = np.mean(time_inside_lung[:,1])
std_valid_time_lung_left = np.std(time_inside_lung[:,1])

mean_valid_time_lung = np.mean(time_inside_lung[:,2])
std_valid_time_lung = np.std(time_inside_lung[:,2])
    
mean_valid_time_out = np.mean(valid_time - time_inside_lung[:,2])
std_valid_time_out = np.std(valid_time - time_inside_lung[:,2])

with open(csv_dir + 'lungcoveragetime.pkl', 'rb') as f:
    data = pickle.load(f)
    
list_coverage = [None] * 48
for i in range(48):
    list_coverage[i] = []

for j in range(46):
    for i in range(tam_csv_time):
        key_name = str(csv_time.LNDid[i]) + '_' + str(csv_time.Radid[i])
        before = 0
        for k in range(len(data[key_name][j])):
            time_coverage = np.zeros(2)
            time_coverage[0] = (k+1) * 100 / len(data[key_name][j])
            time_coverage[1] = (data[key_name][j][k] - before) * 100 / max(data[key_name][j][len(data[key_name][j]) - 1],1)
            before = data[key_name][j][k]
            list_coverage[j].append(time_coverage)    
    list_coverage[j] = np.array(list_coverage[j])

coverage_lung_right = np.zeros([len(list_coverage[j]),2])
coverage_lung_left = np.zeros([len(list_coverage[j]),2])
coverage_lung_right[:,0] = list_coverage[j][:,0]
coverage_lung_left[:,0] = list_coverage[j][:,0]
            
for i in range(len(list_coverage[j])):
    for j in range(46):
        if j < 23:
            coverage_lung_right[i,1] += list_coverage[j][i,1]
        else:
            coverage_lung_left[i,1] += list_coverage[j][i,1]
            
list_coverage[46] = coverage_lung_right
list_coverage[47] = coverage_lung_left

input_parameters = {'mean_valid_time': mean_valid_time,
                    'std_valid_time': std_valid_time,
                    'mean_slice_time': mean_slice_time,
                    'std_slice_time': std_slice_time,
                    'mean_valid_time_lung_right': mean_valid_time_lung_right,
                    'std_valid_time_lung_right': std_valid_time_lung_right,
                    'mean_valid_time_lung_left': mean_valid_time_lung_left,
                    'std_valid_time_lung_left': std_valid_time_lung_left,
                    'mean_valid_time_lung': mean_valid_time_lung,
                    'std_valid_time_lung': std_valid_time_lung,
                    'mean_valid_time_out': mean_valid_time_out,
                    'std_valid_time_out': std_valid_time_out}
df = pandas.DataFrame([input_parameters])
df.to_csv('./carlos_data/generalStats.csv', sep=",",index=False)

input_parameters2 = {'mean_time_inside_sectors': time_inside_sectors[:,0],
                    'std_time_inside_sectors': time_inside_sectors[:,1]}
df2 = pandas.DataFrame(input_parameters2)
df2.to_csv('./carlos_data/time_inside_sectors.csv', sep=",",index=False)

input_parameters3 = {'relative_time': coverage_lung_right[:,0],
                    'coverage_right': coverage_lung_right[:,1],
                    'coverage_left': coverage_lung_left[:,1]}
df3 = pandas.DataFrame(input_parameters3)
df3.to_csv('./carlos_data/relative_coverage.csv', sep=",",index=False)