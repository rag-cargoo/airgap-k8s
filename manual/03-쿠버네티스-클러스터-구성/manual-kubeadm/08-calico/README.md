# 03-02-08. Calico 적용

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/08-calico/`

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make step-03-02-08-calico-run
make step-03-02-08-calico-verify
```

설명: Calico CRD, operator, custom resources를 적용하고 rollout 상태를 확인한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-run-calico.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-verify-calico.sh`

## 검증 기준
```text
[RESULT] SUCCESS
```
