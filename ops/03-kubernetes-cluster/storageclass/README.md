# StorageClass

- 04 서비스 배포 전에 기본 StorageClass를 제공하는 클러스터 애드온을 둔다.
- kubeadm과 Calico는 스토리지 프로비저너를 설치하지 않으므로 이 단계는 별도로 관리한다.
- 1차 선택지는 `local-path-provisioner`다.
- NFS provisioner와 Longhorn은 대안으로 기록하되, 이번 과제의 기본 구현은 local-path 기준으로 진행한다.
- 운영 점검과 장애 대응은 [operation-runbook.md](./operation-runbook.md)에 둔다.

## Asset Plan
- `assets/images.txt`: provisioner/helper 이미지 목록
- `assets/offline-assets/kubernetes/images/storageclass/`: 서버 반입용 이미지 tar
- `assets/offline-assets/kubernetes/manifests/local-path-storage.yaml`: StorageClass manifest
- `scripts/03-03-01-run-storageclass-assets.sh`: master/worker에 StorageClass 이미지와 manifest 반입
- `scripts/03-03-01-verify-storageclass-assets.sh`: master/worker 반입 파일 검증
- `scripts/03-03-02-run-storageclass-image-import.sh`: master/worker containerd 이미지 import
- `scripts/03-03-02-verify-storageclass-image-import.sh`: master/worker 이미지 import 검증
- `scripts/03-03-03-run-storageclass-apply.sh`: local-path-provisioner manifest 적용 및 기본 StorageClass 지정
- `scripts/03-03-03-verify-storageclass-apply.sh`: rollout, 기본 StorageClass, 테스트 PVC/Pod 검증

## Verification
```bash
make 03-03-storageclass-run
make 03-03-storageclass-verify
kubectl get storageclass
kubectl get pvc -A
```

검증 기준은 기본 StorageClass가 보이고 테스트 PVC가 `Bound` 상태가 되는 것이다.

## Step Targets
```bash
make step-03-03-01-storageclass-assets-run
make step-03-03-01-storageclass-assets-verify
make step-03-03-02-storageclass-image-import-run
make step-03-03-02-storageclass-image-import-verify
make step-03-03-03-storageclass-apply-run
make step-03-03-03-storageclass-apply-verify
```

설명: `03-03` StorageClass 단계는 반입, 이미지 import, manifest apply를 순서대로 나누고 각 단계마다 같은 번호의 verify target을 둔다.
