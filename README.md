# 한밭대학교 컴퓨터공학과 NODE 팀 캡스톤디자인   
## FPGA를 이용한 고속 문자열 매칭   

**팀 구성**
- 20207118 김지훈   
- 20171614 박찬우   
- 20207130 조연정   

## 1. 시스템 소개
- 필요성
  - FPGA를 이용하여 저전력 고성능의 string matching 알고리즘을 찾고 적용하여 고성능, 큰 전력 사용량의 서버를 사용하는 대신 네트워크 장비나 string matching이 필요한 어플리케이션에 적용
  - 이후 ASIC으로 변환하여 최대 성능, 최소 전력사용량 달성
  
- 제약사항
  - 사용 board : SK-KV260-G
  - vivado 2021.2 version
  - KV260 ubuntu 22.04 LTS arm64

- 목표
  - 100Gbps의 throughput 구현!
  - 1024, 2048개의 list 비교 기준
  - but 물리적인 한계 존재

## 2. 시스템 사용법
code 디렉토리의 binary 파일 중 TOP.bit.bin, TOP.dtbo, shell.json을 KV260에 복사한다.
```
sudo mkdir /lib/firmware/xilinx/<project>
sudo cp bram.* shell.json /lib/firmware/xilinx/<project>/
sudo xmutil listapps
```
적용된 project가 정상적으로 나타나는것을 확인할 수 있다.   

![target img](./003%20DOC/image/HW/12_target.png)   

```
sudo xmutil unloadapp
sudo xmutil loadapp <project>
```
위 명령어를 이용하여 PL 로직을 load한 이후 *.out 이 저장된 폴더에서
```
sudo ./<project>.out
```
시 정상적으로 실행됨을 확인할 수 있다.

![run image](./003%20DOC/image/HW/run.jpg)   

## 3. 각 시스템별 상세정보
## [DPRAM을 이용한 maximum speed test](./004%20Code/CAP2/kv260_matcher_w_dpram/README.md)    
## [GPIO를 이용한 matcher external test](./004%20Code/CAP2/kv260_matcher_w_gpio/README.md)    
## [RISC-V를 이용한 control test](./004%20Code/CAP2/kv260_matcher_w_risc_v/README.md)    
## [RISC-V 소프트웨어 개발](./004%20Code/CAP2/kv260_matcher_w_risc_v/code/RISC-V/README.md)