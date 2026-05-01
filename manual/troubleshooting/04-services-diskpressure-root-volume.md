# 04 서비스 배포 중 DiskPressure 트러블슈팅

## 증상
04 서비스 배포 중 Pod가 `Pending`, `ImagePullBackOff`, `ContainerCreating` 상태에서 멈출 수 있다.

대표 이벤트:
```text
0/2 nodes are available: 2 node(s) had untolerated taint(s)
node.kubernetes.io/disk-pressure:NoSchedule
The node was low on resource: ephemeral-storage
```

`local-path-provisioner`가 Evicted되면 MariaDB, MongoDB, Prometheus, Grafana PVC가 `Pending` 또는 `WaitForFirstConsumer` 상태로 남을 수 있다.

## 원인
AWS EC2 기본 루트 볼륨이 8GB인 상태에서 Kubernetes/Calico 이미지, offline tar, DB/모니터링 이미지가 같은 루트 파일시스템에 쌓이면 kubelet eviction 기준을 넘는다.

확인 명령:
```bash
df -h /
du -sh /opt/offline-assets /var/lib/containerd /var/lib/kubelet
kubectl describe node k8s-worker1 | grep -E 'Taints:|DiskPressure'
kubectl -n local-path-storage get pods -o wide
```

## 처리 1. 노드 루트 볼륨 확장
Terraform에는 master/worker root volume을 30GB로 명시한다.

```hcl
root_block_device {
  volume_size = var.node_root_volume_size
  volume_type = "gp3"
}
```

현재 실행 중인 AWS 실습 노드는 EBS 볼륨을 30GB로 확장한 뒤 각 노드에서 파티션과 XFS 파일시스템을 늘린다.

```bash
aws ec2 modify-volume --region ap-northeast-2 --volume-id <master-volume-id> --size 30
aws ec2 modify-volume --region ap-northeast-2 --volume-id <worker-volume-id> --size 30

sudo growpart /dev/nvme0n1 1
sudo xfs_growfs -d /
df -h /
```

## 처리 2. 원격 이미지 tar 정리
폐쇄망 원본은 로컬 `assets/offline-assets/`에 남기고, 원격 노드의 tar 파일은 `ctr import` 후 삭제한다.

적용된 정책:
- 03 Kubernetes/Calico/StorageClass 이미지 import 후 원격 tar 삭제
- 04 서비스 이미지 import 후 원격 tar 삭제
- 보존이 필요하면 `AIRGAP_KEEP_REMOTE_K8S_IMAGE_TARS=true` 또는 `AIRGAP_KEEP_REMOTE_SERVICE_IMAGE_TARS=true`를 사용

## 처리 3. StorageClass 복구
DiskPressure로 `local-path-provisioner`가 Evicted되었으면 이미지를 다시 import하고 Pod를 재생성한다.

```bash
make -C ops/03-kubernetes-cluster step-03-02-06-image-import-run
make -C ops/03-kubernetes-cluster step-03-02-06-image-import-verify
make -C ops/03-kubernetes-cluster step-03-03-02-storageclass-image-import-verify

kubectl -n local-path-storage delete pod -l app=local-path-provisioner --ignore-not-found
kubectl -n local-path-storage wait --for=condition=Ready pod -l app=local-path-provisioner --timeout=180s
```

## 완료 확인
```bash
kubectl get nodes -o wide
kubectl describe node k8s-worker1 | grep -E 'Taints:|DiskPressure'
kubectl -n local-path-storage get pods -o wide
make 04-services-monitoring-verify
```

완료 기준:
- worker 노드에 `node.kubernetes.io/disk-pressure:NoSchedule` taint가 없다.
- `local-path-provisioner` Pod가 `1/1 Running`이다.
- 04 서비스 PVC가 모두 `Bound`이다.
- `make 04-services-monitoring-verify`가 성공한다.
