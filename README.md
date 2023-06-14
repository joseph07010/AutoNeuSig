# AutoNeuSig
Automated analysis system for neuronal signal
이 MATLAB

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
