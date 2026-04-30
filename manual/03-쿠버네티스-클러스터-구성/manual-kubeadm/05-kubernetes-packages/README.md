# 03-02-05. Kubernetes 패키지 설치

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/`

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make step-03-02-05-kubernetes-packages-run
make step-03-02-05-kubernetes-packages-verify
```

설명: `kubeadm`, `kubelet`, `kubectl`, `kubernetes-cni`, `cri-tools`를 오프라인 RPM 기준으로 설치한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-run-kubernetes-packages.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-verify-kubernetes-packages.sh`

## 검증 기준
```text
[RESULT] SUCCESS
```
