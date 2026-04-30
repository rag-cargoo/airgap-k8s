# 03. 쿠버네티스 클러스터 구성

## 문서 구성
- `03-01`: [공통 사전점검 및 반입](./01-공통-사전점검-및-반입.md)
- `03-02`: [수동 kubeadm 설치 단계](./02-수동-kubeadm-설치-단계.md)
- `03-03`: [Ansible kubeadm 설치 단계](./03-Ansible-kubeadm-설치-단계.md)
- `03-04`: [Calico 적용 기준](./04-Calico-적용.md)

## 03-01.1. 환경변수 로드
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
```

설명: bastion, master, worker 접속에 필요한 환경변수를 현재 셸에 로드한다.

```bash
cd ops/03-kubernetes-cluster
make help
```

설명: `03-01` 공통 사전점검과 검증 타깃은 `ops/03-kubernetes-cluster/Makefile`, 수동/Ansible 구분 자산은 `common/`, `manual-kubeadm/`, `ansible-kubeadm/`, `calico/` 구조로 확인한다. 수동과 Ansible은 `01`~`06` 같은 단계 번호를 공유한다.

## 03-01.2. bastion 실행 원본 번들 생성
```bash
cd <프로젝트-루트>
make ops-runtime-bundle-run
make ops-runtime-bundle-verify
```

설명: bastion에서 `kubectl`, `helm`, `ansible-playbook`를 실행할 수 있도록 작성 원본 번들 `delivery/ops-runtime.tar.gz`를 준비한다.

## 03-01.3. 실제 원격 preflight 실행
```bash
make 03-01-preflight-run
```

설명: master/worker에 preflight 스크립트를 업로드하고 원격에서 즉시 실행한다. 성공 시 `03-01-remote-preflight.done` 상태 마커를 기록한다.

## 03-01.4. 원격 preflight 재검증
```bash
make 03-01-preflight-verify
```

설명: 이미 업로드된 preflight 스크립트를 master/worker에서 다시 실행해 현재 상태를 재검증한다.

## 03-01.5. 상태 초기화
```bash
make 03-01-preflight-clear
```

설명: `03-01` 실제 preflight 상태 마커만 제거한다. 노드 설정 자체를 되돌리지는 않는다.

## 03-01.6. 사전점검 결과 확인
```text
[OK]   통과
[WARN] 수동 확인 필요
[FAIL] 설치 전 수정 필요
```

설명: `03-01-preflight-run` 또는 `03-01-preflight-verify` 마지막 결과가 `[RESULT] SUCCESS`여야 다음 단계로 진행한다. `FAIL` 항목이 하나라도 있으면 containerd, kubeadm 설치 전에 먼저 수정한다.
