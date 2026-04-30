# 03-02-03. 노드 기본값

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/`

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make step-03-02-03-node-baseline-run
make step-03-02-03-node-baseline-verify
```

설명: master/worker에 커널 모듈, sysctl, swap, hostname 기준을 적용한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-run-node-baseline.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-verify-node-baseline.sh`

## 검증 기준
```text
[RESULT] SUCCESS
```
