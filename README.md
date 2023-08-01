# AutoNeuSig
Automated analysis system for neuronal signal


This MATLAB toolbox is designed for neuronal signal analysis based on MATLAB.
It is designed to allow users to repeatedly apply the analysis to different types of neuronal signal files.

(이 MATLAB toolbox는 MATLAB을 기반으로 신경 신호분석을 위해서 만들어졌습니다.
여러 종류의 신경 신호 파일에 사용자가 반복적으로 분석을 적용할 수 있도록 설계되었습니다.)



**Prerequisite**

To analyze MCD and HDF5 files from the recordings of multichannel systems, first add two libraries to the path of MATLAB.
Also, add one library for connectivity analysis.

(Multichannel systems의 recording 중에서 MCD, HDF5 files를 분석에 사용하기 위해서 우선적으로 MATLAB의 path에 2가지 library를 추가합니다.
또, connectivity analysis를 위해서 1가지 library를 추가합니다.)


1. Neuroshare library
https://www.multichannelsystems.com/software/neuroshare-library

Download the files from the link above and include the MATLAB interface files in the path.

(위의 링크에서 사용자의 컴퓨터에 해당하는 file을 다운로드 받아서 MATLAB interface file들을 path에 포함시킵니다.)



2. McsMatlabDataTools
https://github.com/multichannelsystems/McsMatlabDataTools

Install the library corresponding to the link above.

(위의 링크에 해당하는 library를 설치합니다.)



3. Brain Connectivity Toolbox
https://sites.google.com/site/bctnet/

Download the toolbox from the link above and include it in your MATLAB path.

(위의 링크에서 toolbox를 다운로드 받고 MATLAB path에 포함시킵니다.)



**Installation**

Download the files from this Git, and include the folder in your MATLAB path.

(Git에서 파일을 다운로드 받고, 해당 폴더를 MATLAB path에 포함시킵니다.)



**Example**
'script_example.m'



# connAnalyze
Connectivity analysis tool using NeuroExplorer

This Python-based connectivity analysis toolbox was designed to compute cross-correlation using NeuroExplorer.
It is designed to be able to compute and store cross-corrolgrams iteratively.

(이 Python 기반의 connectivity 분석 toolbox는 NeuroExplorer를 이용해서 cross-correlation을 계산할 수 있게 만들었습니다.
반복적으로 cross-corrolgram을 계산하고, 저장할 수 있게 설계되었습니다.)

**Prerequisite**

Tested on NeuroExplorer version 5 and above.
Installation of NeuroExplorer 5 is required for data calculation.

(NeuroExplorer 5 버젼 이상에서 테스트되었습니다.
데이터 계산을 위해서 NeuroExplorer 5의 설치가 필수적입니다.)

1. With the installed NeuroExplorer turned on, click View > Options... and activate it.

(설치된 NeuroExplorer를 켜둔 상태에서 View > Options..을 활성화합니다.)

2. On the Python tab, click the 'Options for cotrolling NeuroExplorer by running Python in external program...' button.

(Python tab에서 'Options for cotrolling NeuroExplorer by running Python in external program...' 버튼을 누릅니다.)
  
3. Click the 'Start Server Now' button in the popup, and make sure the TCP server is listening.

(팝업에서 'Start Server Now' 버튼을 누르고, TCP server가 listening 상태가 되었는지 확인합니다.)

You can then use the toolbox to analyze connectivity.

(이후 toolbox를 이용해서 connectivity 분석을 진행할 수 있습니다.)
