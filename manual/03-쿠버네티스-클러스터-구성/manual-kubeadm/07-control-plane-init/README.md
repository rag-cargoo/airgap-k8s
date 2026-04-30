# 03-02-07. control-plane 초기화

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/`

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make step-03-02-07-control-plane-init-run
make step-03-02-07-control-plane-init-verify
```

설명: master에서 `kubeadm init`을 실행하고 kubeconfig를 배치한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-run-control-plane-init.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-verify-control-plane-init.sh`

## 검증 기준
```text
[RESULT] SUCCESS
```
