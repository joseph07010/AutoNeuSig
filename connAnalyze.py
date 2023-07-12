import numpy as np
import sys
sys.path.append('C:\\ProgramData\\Nex Technologies\\NeuroExplorer 5 x64')
import nex

class connAnalyze:
    def __init__(self):
        self.doc = nex.NewDocument(25000.0)
        self.chs = {}
        self.trigs = {}
        self.intvs = {}

    def loadMcdData(self, path, activeThre = 0.05, tStart=0): # can be used only for mcd files
        doc = nex.OpenDocument(path)
        tEnd = nex.GetDocEndTime(doc)
        duration = tEnd - tStart

        numCh = nex.GetVarCount(doc, 'neuron')
        chs = {}
        for ii in range(numCh):
            ch = nex.GetVar(doc, ii + 1, 'neuron')
            name = nex.GetName(ch)
            tss = ch.Timestamps()
            tss = [ts for ts in tss if ts > tStart]
            if len(tss) >= activeThre * duration:
                chs[int(name[12:14])] = tss
        
        numTrig = nex.GetVarCount(doc, 'event')
        trigs = {}
        for ii in range(numTrig):
            trig = nex.GetVar(doc, ii + 1, 'event')
            name = 'Trig' + str(ii + 1)
            tss = trig.Timestamps()
            trigs[name] = tss
        nex.CloseDocument(doc)
        
        self.chs = chs
        self.trigs = trigs
    
    def buildInterval(self, manner, name, rise, fall):
        redge = self.parseGetTimestampByLabel(rise)
        if manner == 'risefalledge':
            fedge = self.parseGetTimestampByLabel(fall)
        elif manner == 'timediff':
            diff = float(fall)
            fedge = [edge + diff for edge in redge]
        else:
            raise ValueError('Argument manner should be risefalledge or timediff')
        
        newInt = nex.NewIntEvent(self.doc)
        for ii in range(len(redge)):
            nex.AddInterval(newInt, redge[ii], fedge[ii])
        self.intvs[name] = newInt
        
    def parseGetTimestampByLabel(self, label):
        if '+' in label:
            tokens = label.split('+')
            name = tokens[0].strip()
            gap = float(tokens[1].strip())
        elif '-' in label:
            tokens = label.split('-')
            name = tokens[0].strip()
            gap = float(tokens[1].strip())
        else:
            name = label.strip()
            gap = 0
        tss = self.getTimestampByLabel(name)
        tss = [ts + gap for ts in tss]
        
        return tss
    
    def getTimestampByLabel(self, label):
        if not label in self.trigs.keys():
            raise ValueError('Invalid name of trigger')
        return self.trigs[label]
    
    def getInterval(self, name):
        return self.intvs[name]
    
    def applyCrosscorr(self, binedge, jitter=False, jitWindow=0.005, reptNum=100, intvFilt='None', printmode=False):
        chs = self.chs
        neurons = chs.keys()
        doc = self.doc

        eTime = 0
        for n in neurons:
            doc[str(n)] = nex.NewEvent(doc, 0)
            doc[str(n)].SetTimestamps(chs[n])

            eTime = max(eTime, max(chs[n]))

        nex.SetDocEndTime(doc, round(eTime) + 1)
        
        if intvFilt == 'None':
            pass
        else:
            doc[intvFilt] = self.intvs[intvFilt]

        binsize = str(binedge[1] - binedge[0])
        nex.ModifyTemplate(doc, 'Crosscorrelograms', 'XMin (sec)', str(binedge[0]))
        nex.ModifyTemplate(doc, 'Crosscorrelograms', 'XMax (sec)', str(binedge[-1]))
        nex.ModifyTemplate(doc, 'Crosscorrelograms', 'Bin (sec)', binsize)
        nex.ModifyTemplate(doc, 'Crosscorrelograms', 'Normalization', 'Counts/Bin')
        nex.ModifyTemplate(doc, 'Crosscorrelograms', 'Smooth', 'None')
        nex.ModifyTemplate(doc, 'Crosscorrelograms', 'Interval Filter', intvFilt)

        nex.ModifyTemplate(doc, 'Crosscorrelograms', 'Send to Matlab', '0')

        connAnalyze.selectRefresh(doc, neurons)
        corr = []
        jitCorrMean = []
        jitCorrStd = []
        for n in neurons:
            if n % 10 == 1 and printmode:
                print('%dth neuron start'%n)
            if jitter:
                for ii in range(reptNum):
                    doc[str(n)] = nex.NewEvent(doc, 0)
                    doc[str(n)].SetTimestamps(connAnalyze.jitterSpike(chs[n], jitWindow))
                    connAnalyze.selectRefresh(doc, neurons)

                    res = connAnalyze.crosscorrByNE(doc, str(n))
                    if ii==0:
                        corrMean = np.array(res)
                        corrStd = np.square(res)
                    else:
                        corrMean += res
                        corrStd += np.square(res)
                corrMean /= reptNum
                corrStd /= reptNum
                corrStd -= np.square(corrMean)
                corrStd = np.sqrt(corrStd)

                jitCorrMean.append(corrMean.tolist())
                jitCorrStd.append(corrStd.tolist())

                doc[str(n)] = nex.NewEvent(doc, 0)
                doc[str(n)].SetTimestamps(chs[n])
                connAnalyze.selectRefresh(doc, neurons)

            res = connAnalyze.crosscorrByNE(doc, str(n))
            corr.append(res)

        nex.CloseDocument(doc)
        self.doc = nex.NewDocument(25000.0)

        return corr, jitCorrMean, jitCorrStd
    
    @staticmethod
    def loadSimData(path, tStart=100): # can be used only for simulation data
        with open(path, 'r') as f:
            raw = f.read()
        data = raw.split('\n')

        spks = []
        for d in data:
            if d: # only if not empty
                spk = d.split('\t')
                if float(spk[1]) / 1000 >= tStart:
                    # spike times in sec
                    spks.append((int(spk[0]), float(spk[1]) / 1000 - tStart))

        return spks # containing every neurons' spikes
    
    @staticmethod
    def arangeSpks(spks): # in order to arange spikes according to neurons
        chNums = list(set([spk[0] for spk in spks]))
        chs = dict((num, []) for num in chNums)

        for ch, ts in spks:
            chs[ch].append(ts)
        return chs # dictionary with neuron numbers


    @staticmethod
    def selectRefresh(doc, neurons):
        nex.DeselectAll(doc)
        for n in neurons:
            nex.Select(doc, doc[str(n)])
        return

    @staticmethod
    def jitterSpike(spksFromNeuron, sigma):
        numSpk = len(spksFromNeuron)
        jitParam = np.random.normal(0, sigma, numSpk)
        jitted = np.sort(np.array(spksFromNeuron) + jitParam)

        return jitted[jitted > 0].tolist()

    @staticmethod
    def saveCorrResult(path, chs, binedge, corr, jitMean, jitStd):
        with open(path + '.corr', 'w') as f:
            f.write(str(len(chs)) + '\n') # the number of channels

            for key in chs.keys(): # channel numbers
                f.write(str(key) + '\t')
            f.write('\n')

            for key in chs.keys(): # the number of spikes
                f.write(str(len(chs[key])) + '\t')
            f.write('\n')

            f.write(str(len(binedge) - 1) + '\n') # length of correlation

            binsize = binedge[1] - binedge[0] # time axis
            for bin in binedge[:-1]:
                f.write(str(round(bin + binsize / 2, 3)) + '\t')
            f.write('\n')

            for corrSet in corr: # cross-correlation
                for corrSeries in corrSet:
                    for value in corrSeries:
                        f.write(str(value) + '\t')
                    f.write('\n')

            for jitSet in jitMean: # jittered correlation mean
                for jitSeries in jitSet:
                    for value in jitSeries:
                        f.write(str(value) + '\t')
                    f.write('\n')

            for jitSet in jitStd: # jittered correlation std
                for jitSeries in jitSet:
                    for value in jitSeries:
                        f.write(str(value) + '\t')
                    f.write('\n')
        return

    @staticmethod
    def saveCorrResult_old(path, chs, corrLength, corr, jitMean, jitStd):
        with open(path, 'w') as f:
            f.write(str(len(chs)) + '\t' + str(corrLength) + '\n')

            for key in chs.keys():
                f.write(str(key) + '\t')
            f.write('\n')

            for corrSet in corr:
                for corrSeries in corrSet:
                    for value in corrSeries:
                        f.write(str(value) + '\t')
                    f.write('\n')

            for jitSet in jitMean:
                for jitSeries in jitSet:
                    for value in jitSeries:
                        f.write(str(value) + '\t')
                    f.write('\n')

            for jitSet in jitStd:
                for jitSeries in jitSet:
                    for value in jitSeries:
                        f.write(str(value) + '\t')
                    f.write('\n')

        return

    @staticmethod
    def openCorrResult(path):
        with open(path, 'r') as f:
            raw = f.read()
        lines = raw.split('\n')
        numNeuron = int(lines[0].split('\t')[0])
        corrLength = int(lines[0].split('\t')[1])

        chs = list(map(int, lines[1].split('\t')[:-1]))

        lines = lines[2:-1]
        corr = []
        for ii in range(numNeuron):
            corrSeries = []
            for jj in range(numNeuron):
                corrSeries.append(map(float, lines[ii * numNeuron + jj].split('\t')[:-1]))
            corr.append(corrSeries)

        lines = lines[numNeuron**2:]
        jitMean = []
        for ii in range(numNeuron):
            jitSeries = []
            for jj in range(numNeuron):
                jitSeries.append(map(float, lines[ii * numNeuron + jj].split('\t')[:-1]))
            jitMean.append(jitSeries)

        lines = lines[numNeuron**2:]
        jitStd = []
        for ii in range(numNeuron):
            jitSeries = []
            for jj in range(numNeuron):
                jitSeries.append(map(float, lines[ii * numNeuron + jj].split('\t')[:-1]))
            jitStd.append(jitSeries)

        return numNeuron, corrLength, chs, corr, jitMean, jitStd

    @staticmethod
    def extractConn():
        connMap = []
        connPk = []
        connDly = []
        return connMap, connPk, connDly

    @staticmethod
    def saveConnResult(path, numNeuron, connMap, connWght, connDly):
        with open(path, 'w') as f:
            f.write(str(numNeuron) + '\n')
            for conns in connMap:
                for conn in conns:
                    f.write(str(conn) + '\t')
                f.write('\n')
            for wghts in connWght:
                for wght in wghts:
                    f.write(str(wght) + '\t')
                f.write('\n')
            for dlys in connDly:
                for dly in dlys:
                    f.write(str(dly) + '\t')
                f.write('\n')

        return

    @staticmethod
    def openConnResult(path):
        with open(path, 'r') as f:
            raw = f.read()
        lines = raw.split('\n')
        numNeuron = int(lines[0])

        lines = lines[1:-1]
        connMap = []
        for ii in range(numNeuron):
            connMap.append(map(int, lines[ii].split('\t')[:-1]))

        lines = lines[numNeuron:]
        connWght = []
        for ii in range(numNeuron):
            connWght.append(map(float, lines[ii].split('\t')[:-1]))

        lines = lines[numNeuron:]
        connDly = []
        for ii in range(numNeuron):
            connDly.append(map(float, lines[ii].split('\t')[:-1]))

        return numNeuron, connMap, connWght, connDly

    @staticmethod
    def crosscorrByNE(doc, ref): # the fastest way using NE
        nex.ModifyTemplate(doc, 'Crosscorrelograms', 'Reference', ref)
        nex.ApplyTemplate(doc, 'Crosscorrelograms')

        res = doc.GetAllNumericalResults()

        return res[1:]

    @staticmethod
    def crosscorr(ref, to, binedge): # 5 times slower than MATLAB
        corr = np.zeros(len(binedge) - 1)
        for t1 in ref:
            histcount = np.histogram(to, binedge + t1)[0]
            corr += histcount

        return corr

    @staticmethod
    def crosscorr2(ref, to, binedge):
        binsize = binedge[1] - binedge[0]
        tspan = max(max(ref), max(to))
        histx = np.arange(0, tspan + binsize, binsize)

        refHist = np.histogram(ref, histx)[0]
        toHist = np.histogram(to, histx)[0]

        corr = np.correlate(refHist, toHist)

        return corr

    @staticmethod
    def crosscorr3(ref, to, binedge): # 0.8 times slower than MATLAB
        #ref = np.array(ref)
        #to = np.array(to)
        temp = np.array([])

        for t1 in ref:
            to2 = to - t1
            temp = np.append(temp, to2[np.where(np.logical_and(to2 >= binedge[0], to2 < binedge[-1]))])
        corr = np.histogram(temp, binedge)[0]

        return corr

    @staticmethod
    def smoothCorr(corr, smoothWindow=5):
        return np.convolve(corr, np.ones(smoothWindow), 'valid')
