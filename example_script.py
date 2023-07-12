import os
from connAnalyze import connAnalyze as ca
import numpy as np
import time

path = '.\\Test_files\\Interval'
pathlist = os.listdir(path)
files = [path + '\\' + file for file in pathlist]

binedge = np.arange(-0.1, 0.1 + 0.002, 0.002)
myca = ca()

t = time.time()
for file in pathlist:
    print(file + ': start')

    myca.loadMcdData(path + '\\' + file)
    corr, jitCorrMean, jitCorrStd  = myca.applyCrosscorr(binedge, jitter=True, jitWindow=0.025, reptNum=5)
    savefile = path + '\\' + file.split('.')[0] + '_corr_jit0.005'
    myca.saveCorrResult(savefile, myca.chs, binedge, corr, jitCorrMean, jitCorrStd)
    
    myca.buildInterval('risefalledge', 'int1', 'Trig1', 'Trig2')
    corr, jitCorrMean, jitCorrStd  = myca.applyCrosscorr(binedge, jitter=True, jitWindow=0.025, reptNum=5, intvFilt='int1')
    savefile = path + '\\' + file.split('.')[0] + '_int1'
    myca.saveCorrResult(savefile, myca.chs, binedge, corr, jitCorrMean, jitCorrStd)
    
    myca.buildInterval('timediff', 'int2', 'Trig1-30', 30)
    corr, jitCorrMean, jitCorrStd  = myca.applyCrosscorr(binedge, jitter=True, jitWindow=0.025, reptNum=5, intvFilt='int2')
    savefile = path + '\\' + file.split('.')[0] + '_int2'
    myca.saveCorrResult(savefile, myca.chs, binedge, corr, jitCorrMean, jitCorrStd)

print(time.time() - t)
