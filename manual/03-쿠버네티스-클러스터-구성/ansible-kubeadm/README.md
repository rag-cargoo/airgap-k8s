# Ansible kubeadm 설치 단계

## 대응 경로
- `ops/03-kubernetes-cluster/ansible-kubeadm/`

## 단계 구조
1. [01-node-baseline](./01-node-baseline/README.md)
2. [02-containerd](./02-containerd/README.md)
3. [03-kubernetes-packages](./03-kubernetes-packages/README.md)
4. [04-control-plane-init](./04-control-plane-init/README.md)
5. [05-calico](./05-calico/README.md)
6. [06-worker-join](./06-worker-join/README.md)

설명: Ansible 설치도 ops의 `ansible-kubeadm/01..06` 디렉터리와 같은 단계 번호를 공유한다. inventory, SSH 설정, bastion/control-node 분기는 공통 bootstrap 기준으로 맞춘다. 현재 `03-03-ansible-kubeadm-verify` target은 아직 미구현이다.
