# Calico 적용 기준

## 대응 경로
- `ops/03-kubernetes-cluster/calico/`

## 기준
- CNI는 `Calico`로 확정한다.
- 오프라인 자산에는 Calico manifest와 Calico 컨테이너 이미지 tar를 포함한다.
- 수동 설치는 `manual-kubeadm/08-calico`, Ansible 설치는 `ansible-kubeadm/05-calico` 단계에서 같은 CNI 기준을 사용한다.

## 이미지 기준
```text
quay.io/tigera/operator:v1.40.7
quay.io/calico/cni:v3.31.4
quay.io/calico/key-cert-provisioner:v3.31.4
quay.io/calico/kube-controllers:v3.31.4
quay.io/calico/node:v3.31.4
quay.io/calico/typha:v3.31.4
quay.io/calico/pod2daemon-flexvol:v3.31.4
quay.io/calico/apiserver:v3.31.4
quay.io/calico/csi:v3.31.4
quay.io/calico/node-driver-registrar:v3.31.4
quay.io/calico/goldmane:v3.31.4
quay.io/calico/whisker:v3.31.4
quay.io/calico/whisker-backend:v3.31.4
```

설명: 위 이미지는 `assets/offline-assets/kubernetes/images/calico/images.txt` 기준으로 관리한다. 하나라도 빠지면 폐쇄망 노드에서 `ErrImagePull` 또는 `ImagePullBackOff`가 발생할 수 있다.

## 참고
- 과제 원문에 남아 있는 `Calico 또는 Flannel` 표기는 `manual/00-제출-매뉴얼-개요/01-과제-원문.md` 원문 보존 목적이다.
- 현재 운영 기준 문서와 실행 경로는 모두 `Calico` 기준으로 본다.
