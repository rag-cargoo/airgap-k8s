# 03-02-01. 접속 및 반입

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/`

설명: `common/` 디렉터리는 03 수동 설치 흐름에서 사용하지 않는다. 접속 경로와 반입 상태 확인은 `manual-kubeadm/01-access-and-transfer`가 담당한다.

## 실행 순서
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
make ops-runtime-bundle-run
make ops-runtime-bundle-verify
cd ops/03-kubernetes-cluster
make step-03-02-01-access-and-transfer-run
make step-03-02-01-access-and-transfer-verify
```

설명: bastion, master, worker SSH 경로와 `/opt/offline-assets` 반입 상태를 확인한다. `ops-runtime-bundle-*`는 bastion에서 실행할 ops 원본을 `delivery/ops-runtime.tar.gz`로 준비한다.

## 검증 기준
```text
[RESULT] SUCCESS
```

설명: `step-03-02-01-access-and-transfer-verify`가 `SUCCESS`여야 다음 설치 단계로 진행한다.

## 관련 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-01-render-env-from-survey-yaml.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-run-access-and-transfer.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-verify-access-and-transfer.sh`
