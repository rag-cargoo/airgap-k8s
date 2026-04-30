# 03-03. Ansible kubeadm 설치 단계

## 대응 경로
- `ops/03-kubernetes-cluster/ansible-kubeadm/`

## 단계 구조
1. `01-node-baseline`
2. `02-containerd`
3. `03-kubernetes-packages`
4. `04-control-plane-init`
5. `05-calico`
6. `06-worker-join`

설명: Ansible 설치도 수동 설치와 같은 6개 단계 번호를 공유한다. inventory, SSH 설정, bastion/control-node 분기는 공통 bootstrap 기준으로 맞춘다.
