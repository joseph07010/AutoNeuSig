# AutoNeuSig
Automated analysis system for neuronal signal

이 MATLAB toolbox는 MATLAB을 기반으로 신경 신호분석을 위해서 만들어졌습니다.
여러 종류의 신경 신호 파일에 사용자가 반복적으로 분석을 적용할 수 있도록 설계되었습니다.


**Prerequisite**

Multichannel systems의 recording 중에서 MCD, HDF5 files를 분석에 사용하기 위해서 우선적으로 MATLAB의 path에 2가지 library를 추가합니다.
또, connectivity analysis를 위해서 1가지 library를 추가합니다.

1. Neuroshare library
https://www.multichannelsystems.com/software/neuroshare-library

위의 링크에서 사용자의 컴퓨터에 해당하는 file을 다운로드 받아서 MATLAB interface file들을 path에 포함시킵니다.

2. McsMatlabDataTools
https://github.com/multichannelsystems/McsMatlabDataTools

위의 링크에 해당하는 library를 설치합니다.

3. Brain Connectivity Toolbox
https://sites.google.com/site/bctnet/

위의 링크에서 toolbox를 다운로드 받고 MATLAB path에 포함시킵니다.

**Installation**

파일을 다운로드 받고, 해당 폴더를 MATLAB path에 포함시킵니다.

**Example**
'script_example.m'

# connAnalyze
Connectivity analysis tool using NeuroExplorer

이 Python 기반의 connectivity 분석 toolbox는 NeuroExplorer를 이용해서 cross-correlation을 계산할 수 있게 만들었습니다.
반복적으로 cross-corrolgram을 계산하고, 저장할 수 있게 설계되었습니다.

**Prerequisite**

NeuroExplorer 5 버젼 이상에서 테스트되었습니다.
데이터 계산을 위해서 NeuroExplorer 5의 설치가 필수적입니다.

1. 설치된 NeuroExplorer를 켜둔 상태에서 View > Options..을 활성화합니다.
2. Python tab에서 'Options for cotrolling NeuroExplorer by running Python in external program...' 버튼을 누릅니다.
3. 팝업에서 'Start Server Now' 버튼을 누르고, TCP server가 listening 상태가 되었는지 확인합니다.

이후 toolbox를 이용해서 connectivity 분석을 진행할 수 있습니다.
