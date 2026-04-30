# Manual kubeadm

수동 kubeadm 설치 실행 원본이다. 각 단원 디렉터리의 `scripts/` 아래에 실행 스크립트와 검증 스크립트를 둔다.

## Step Map
| 순서 | 디렉터리 | helper | 실행 | 검증 |
| --- | --- | --- | --- | --- |
| `01` | `01-access-and-transfer/` | `01-01-render-env-from-survey-yaml.sh` | `01-02-run-access-and-transfer.sh` | `01-02-verify-access-and-transfer.sh` |
| `02` | `02-preflight/` | `02-01-kubeadm-preflight-check.sh` | `02-02-run-preflight.sh` | `02-02-verify-preflight.sh` |
| `03` | `03-node-baseline/` | 없음 | `03-01-run-node-baseline.sh` | `03-01-verify-node-baseline.sh` |
| `04` | `04-containerd/` | 없음 | `04-01-run-containerd.sh` | `04-01-verify-containerd.sh` |
| `05` | `05-kubernetes-packages/` | 없음 | `05-01-run-kubernetes-packages.sh` | `05-01-verify-kubernetes-packages.sh` |
| `06` | `06-image-import/` | 없음 | `06-01-run-image-import.sh` | `06-01-verify-image-import.sh` |
| `07` | `07-control-plane-init/` | 없음 | `07-01-run-control-plane-init.sh` | `07-01-verify-control-plane-init.sh` |
| `08` | `08-calico/` | 없음 | `08-01-run-calico.sh` | `08-01-verify-calico.sh` |
| `09` | `09-worker-join/` | 없음 | `09-01-run-worker-join.sh` | `09-01-verify-worker-join.sh` |
| `10` | `10-cluster-verify/` | `10-02-troubleshoot-cluster.sh`, `10-03-local-kubectl-access.sh` | 없음 | `10-01-verify-cluster.sh` |

## 실행 기준
```bash
cd <프로젝트-루트>/ops/03-kubernetes-cluster
make 03-02-manual-kubeadm-run
make 03-02-manual-kubeadm-verify
```

설명: 전체 실행 target은 위 단원별 run/verify 스크립트를 순서대로 호출한다. 개별 장애 위치를 좁힐 때는 `step-03-02-<번호>-<이름>-run` 또는 `verify` target을 직접 실행한다.

## 번호 기준
- 파일명은 `단원-세부순서-역할` 형식을 사용한다.
- 같은 작업 단위의 `run`과 `verify`는 같은 세부순서를 공유한다.
- helper나 진단 스크립트는 실행 순서에 맞춰 별도 세부순서를 사용한다.
