# 03-02. 수동 kubeadm 설치 단계

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/`

## 단계 구조
| 순서 | manual 문서 | ops 디렉터리 | 실행 target | 검증 target | 수행 내용 |
| --- | --- | --- | --- | --- | --- |
| `03-02-01` | [01-access-and-transfer](./01-access-and-transfer/README.md) | `manual-kubeadm/01-access-and-transfer/` | `step-03-02-01-access-and-transfer-run` | `step-03-02-01-access-and-transfer-verify` | bastion/master/worker SSH 경로 확인, 오프라인 자산 반입 상태 확인 |
| `03-02-02` | [02-preflight](./02-preflight/README.md) | `manual-kubeadm/02-preflight/` | `step-03-02-02-preflight-run` | `step-03-02-02-preflight-verify` | master/worker 원격 kubeadm 사전점검 |
| `03-02-03` | [03-node-baseline](./03-node-baseline/README.md) | `manual-kubeadm/03-node-baseline/` | `step-03-02-03-node-baseline-run` | `step-03-02-03-node-baseline-verify` | 커널 모듈, sysctl, swap, hostname 기준 적용 |
| `03-02-04` | [04-containerd](./04-containerd/README.md) | `manual-kubeadm/04-containerd/` | `step-03-02-04-containerd-run` | `step-03-02-04-containerd-verify` | `containerd`, `runc`, CNI/CRI 도구 설치 및 설정 |
| `03-02-05` | [05-kubernetes-packages](./05-kubernetes-packages/README.md) | `manual-kubeadm/05-kubernetes-packages/` | `step-03-02-05-kubernetes-packages-run` | `step-03-02-05-kubernetes-packages-verify` | `kubeadm`, `kubelet`, `kubectl` 오프라인 RPM 설치 |
| `03-02-06` | [06-image-import](./06-image-import/README.md) | `manual-kubeadm/06-image-import/` | `step-03-02-06-image-import-run` | `step-03-02-06-image-import-verify` | Kubernetes/Calico 컨테이너 이미지 import |
| `03-02-07` | [07-control-plane-init](./07-control-plane-init/README.md) | `manual-kubeadm/07-control-plane-init/` | `step-03-02-07-control-plane-init-run` | `step-03-02-07-control-plane-init-verify` | master `kubeadm init`, kubeconfig 배치 |
| `03-02-08` | [08-calico](./08-calico/README.md) | `manual-kubeadm/08-calico/` | `step-03-02-08-calico-run` | `step-03-02-08-calico-verify` | Calico CRD/operator/custom resources 적용 |
| `03-02-09` | [09-worker-join](./09-worker-join/README.md) | `manual-kubeadm/09-worker-join/` | `step-03-02-09-worker-join-run` | `step-03-02-09-worker-join-verify` | worker join command 생성 및 worker 노드 join |
| `03-02-10` | [10-cluster-verify](./10-cluster-verify/README.md) | `manual-kubeadm/10-cluster-verify/` | 없음 | `step-03-02-10-cluster-verify` | 노드 Ready, Calico rollout, image pull failure 최종 확인 |
| `03-02-10-local` | [내 PC kubectl 접속](./10-cluster-verify/local-kubectl-access.md) | `manual-kubeadm/10-cluster-verify/` | `03-02-local-kubectl-setup` | `03-02-local-kubectl-status` | 내 PC 기본 `kubectl` 접속 설정 |

설명: `03-02-manual-kubeadm-run`은 위 `03-02-01`부터 `03-02-10`까지 같은 순서로 묶어 실행/검증한다. 개별 장애 대응이나 재실행이 필요하면 각 step target을 직접 실행한다.

## OS 기준
- 대상 노드 OS는 `Amazon Linux 2023`
- 패키지 방식은 `rpm/dnf`
- container runtime은 `containerd`
- CNI는 `Calico`

## 전체 자동 실행 명령
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster
make 03-02-manual-kubeadm-run
make 03-02-manual-kubeadm-verify
```

설명: 전체 자동 실행은 `01 -> 02 -> 03 -> 04 -> 05 -> 06 -> 07 -> 08 -> 09 -> 10` 순서로 진행하고, 성공하면 `03-manual-kubeadm-install.done` 상태 마커를 기록한다.

## 단계별 실행 명령
```bash
cd <프로젝트-루트>
source ops/01-airgap-linux-environment/scripts/load-project-env.sh
cd ops/03-kubernetes-cluster

make step-03-02-01-access-and-transfer-run
make step-03-02-01-access-and-transfer-verify
make step-03-02-02-preflight-run
make step-03-02-02-preflight-verify
make step-03-02-03-node-baseline-run
make step-03-02-03-node-baseline-verify
make step-03-02-04-containerd-run
make step-03-02-04-containerd-verify
make step-03-02-05-kubernetes-packages-run
make step-03-02-05-kubernetes-packages-verify
make step-03-02-06-image-import-run
make step-03-02-06-image-import-verify
make step-03-02-07-control-plane-init-run
make step-03-02-07-control-plane-init-verify
make step-03-02-08-calico-run
make step-03-02-08-calico-verify
make step-03-02-09-worker-join-run
make step-03-02-09-worker-join-verify
make step-03-02-10-cluster-verify
```

설명: 각 단원은 `run`과 `verify`를 분리한다. `10-cluster-verify`는 최종 검증 전용 단계이므로 별도 run 스크립트가 없다.

## 작성된 스크립트
- `ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-01-render-env-from-survey-yaml.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-run-access-and-transfer.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/01-access-and-transfer/scripts/01-02-verify-access-and-transfer.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-01-kubeadm-preflight-check.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-run-preflight.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/02-preflight/scripts/02-02-verify-preflight.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-run-node-baseline.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/03-node-baseline/scripts/03-01-verify-node-baseline.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-run-containerd.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/04-containerd/scripts/04-01-verify-containerd.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-run-kubernetes-packages.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/05-kubernetes-packages/scripts/05-01-verify-kubernetes-packages.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-run-image-import.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/06-image-import/scripts/06-01-verify-image-import.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-run-control-plane-init.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/07-control-plane-init/scripts/07-01-verify-control-plane-init.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-run-calico.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/08-calico/scripts/08-01-verify-calico.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-run-worker-join.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/09-worker-join/scripts/09-01-verify-worker-join.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-01-verify-cluster.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-02-troubleshoot-cluster.sh`
- `ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh`

설명: 스크립트 파일명은 `단원-세부순서-역할` 순서로 둔다. `run`과 `verify`가 같은 작업 단위이면 같은 세부순서를 공유하고, helper는 먼저 오는 별도 세부순서를 사용한다. 설치 명령은 각 단원 스크립트에 직접 들어 있으며 `manual-kubeadm/scripts/manual-kubeadm-lib.sh` 같은 상위 공용 설치 본체는 사용하지 않는다.

## 실제 성공 결과
```text
[RESULT] SUCCESS
[TARGET] 03-02-manual-kubeadm-verify
[KIND] verify
```

```text
NAME          STATUS   ROLES           VERSION   INTERNAL-IP    CONTAINER-RUNTIME
k8s-master    Ready    control-plane   v1.35.4   10.10.20.151   containerd://2.2.1+unknown
k8s-worker1   Ready    <none>          v1.35.4   10.10.20.154   containerd://2.2.1+unknown
```

설명: 수동 kubeadm 설치 검증 결과 master와 worker가 모두 `Ready` 상태이고, Calico 관련 Pod의 `ErrImagePull` / `ImagePullBackOff`가 없는 상태로 확인됐다.

## 장애 진단 명령
```bash
cd <프로젝트-루트>/ops/03-kubernetes-cluster
make 03-02-manual-kubeadm-troubleshoot
```

설명: 설치가 오래 걸리거나 실패 위치가 명확하지 않으면 이 명령으로 전송 상태, 패키지 설치 상태, 서비스 상태, 클러스터 상태를 먼저 확인한다.

## 내 PC 기본 kubectl 접속
상세: [내 PC kubectl 접속](./10-cluster-verify/local-kubectl-access.md)

```bash
cd <프로젝트-루트>
make 03-02-local-kubectl-install
make 03-02-local-kubectl-setup
kubectl get nodes
make 03-02-local-kubectl-stop
```

설명: 권장 방식이다. `export KUBECONFIG=...`를 직접 실행하지 않고 plain `kubectl get nodes`를 쓴다. `install`은 sudo 없이 `~/.local/bin/kubectl`에 설치한다. `setup`은 `.env`를 내부에서 로드하고, 기존 `~/.kube/config`가 있으면 최초 1회 `~/.kube/config.backup-before-airgap-k8s`로 백업한 뒤 `airgap-k8s` context를 병합/업데이트한다. 반복 실행해도 같은 context가 계속 추가되지 않는다.

## 내 PC kubeconfig 직접 지정 접속
```bash
cd <프로젝트-루트>
make 03-02-local-kubectl-start
kubectl --kubeconfig .kube/airgap-k8s-admin.conf get nodes
make 03-02-local-kubectl-stop
```

설명: 기본 kubeconfig를 건드리지 않고 프로젝트 내부 `.kube/airgap-k8s-admin.conf`만 사용하고 싶을 때의 선택 방식이다.

## 상태 초기화
```bash
make 03-02-manual-kubeadm-clear
```

설명: `03-02` 상태 마커만 제거한다. 실제 Kubernetes 클러스터, 패키지, 설정은 되돌리지 않는다.

## 성공 기준
```text
[RESULT] SUCCESS
```

설명: `03-02-manual-kubeadm-verify` 마지막 결과가 `SUCCESS`이고, master에서 `kubectl get nodes` 결과에 `k8s-master`, `k8s-worker1` 두 노드가 모두 `Ready`로 보여야 한다.
