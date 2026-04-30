# 내 PC kubectl 접속

## 대응 경로
- `ops/03-kubernetes-cluster/manual-kubeadm/10-cluster-verify/scripts/10-03-local-kubectl-access.sh`

## 목적
내 PC에서 `kubectl get nodes`처럼 기본 `kubectl` 명령으로 airgap Kubernetes 클러스터에 접속한다.

## 권장 실행 순서
```bash
cd <프로젝트-루트>
make 03-02-local-kubectl-install
make 03-02-local-kubectl-setup
kubectl get nodes
```

설명: `source`나 `export KUBECONFIG=...`를 직접 실행하지 않는다. `setup` target이 `.env`를 내부에서 로드하고, kubeconfig 병합과 SSH 터널 시작까지 처리한다.

## 접속 상태 확인
```bash
make 03-02-local-kubectl-status
kubectl get nodes
kubectl get ns
kubectl get pods -A
```

## 접속 종료
```bash
make 03-02-local-kubectl-stop
```

설명: 내 PC에서 Kubernetes API로 붙기 위해 열어둔 백그라운드 SSH 터널을 종료한다.

## 동작 방식
- `kubectl`이 없으면 `make 03-02-local-kubectl-install`로 `~/.local/bin/kubectl`에 설치한다.
- master의 `/etc/kubernetes/admin.conf`를 SSH로 가져와 프로젝트 내부 `.kube/airgap-k8s-admin.conf`에 저장한다.
- `~/.kube/config`가 없으면 생성하고, 있으면 최초 1회 `~/.kube/config.backup-before-airgap-k8s`로 백업한다.
- `airgap-k8s` context를 병합/업데이트한다.
- 반복 실행해도 같은 context가 계속 추가되지 않는다.
- SSH 터널은 `127.0.0.1:16443 -> master 127.0.0.1:6443` 구조로 열린다. bastion 환경에서는 bastion을 SSH ProxyCommand로 경유한다.

## 기본 kubeconfig를 변경하지 않는 방식
```bash
cd <프로젝트-루트>
make 03-02-local-kubectl-start
kubectl --kubeconfig .kube/airgap-k8s-admin.conf get nodes
make 03-02-local-kubectl-stop
```

설명: `~/.kube/config`를 변경하지 않고 프로젝트 내부 kubeconfig만 직접 지정해서 쓰는 선택 방식이다.

## 성공 기준
```text
NAME          STATUS   ROLES           VERSION
k8s-master    Ready    control-plane   v1.35.4
k8s-worker1   Ready    <none>          v1.35.4
```
