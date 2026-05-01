# StorageClass 구성 기준

운영 기준과 장애 대응은 [StorageClass 운영 매뉴얼](./operations.md)에서 별도로 관리한다.

## 03-03.1 현재 StorageClass 확인
```bash
kubectl get storageclass
```

설명: `No resources found`가 나오면 클러스터에 기본 StorageClass가 없는 상태다.

## 03-03.2 PVC 영향 확인
```bash
kubectl get pvc -A
```

설명: 기본 StorageClass가 없으면 MySQL, MongoDB, Prometheus, Grafana가 PVC를 요청할 때 자동 PV 생성이 되지 않아 PVC가 `Pending` 상태에 머물 수 있다.

## 03-03.3 필요한 이유
- `kubeadm`은 control plane과 node bootstrap을 담당한다.
- `Calico`는 Pod 네트워크를 담당한다.
- 둘 다 스토리지 프로비저너를 설치하지 않는다.
- PVC를 자동으로 PV에 연결하려면 별도 StorageClass와 provisioner가 필요하다.

## 03-03.4 해결 방식
| 방식 | 용도 | 기준 |
| --- | --- | --- |
| `local-path-provisioner` | 단일/소규모 kubeadm 실습 클러스터의 기본 동적 프로비저닝 | 1차 선택 |
| NFS provisioner | 여러 노드에서 공유 스토리지를 제공해야 하는 경우 | 대안 |
| Longhorn | 운영형 분산 블록 스토리지를 구성하는 경우 | 후순위 대안 |
| static PV / hostPath | 임시 검증 또는 장애 fallback | 기본 선택 아님 |

## 03-03.5 이번 과제 기준
- 04 서비스 배포 전 `local-path-provisioner` 기반 기본 StorageClass를 먼저 구성한다.
- 폐쇄망 반입 자산에는 provisioner 이미지와 manifest를 포함한다.
- local-path는 노드 로컬 디스크 기반이므로 운영급 HA 스토리지는 아니라는 점을 제출 매뉴얼에 명시한다.

## 03-03.6 StorageClass 적용
```bash
cd <프로젝트-루트>
make 03-03-storageclass-run
```

설명: master/worker에 local-path-provisioner와 helper 이미지를 import하고, master에서 `local-path-storage.yaml`을 적용한 뒤 `local-path` StorageClass를 기본값으로 지정한다.

## 03-03.7 구성 후 검증
```bash
make 03-03-storageclass-verify
```

설명: provisioner rollout, 기본 StorageClass annotation, 테스트 PVC `Bound`, 테스트 Pod volume 쓰기/읽기를 검증한다.

## 03-03.8 구성 후 확인 명령
```bash
kubectl get storageclass
kubectl get pvc -A
```

설명: 기본 StorageClass가 보이고, 테스트 PVC가 `Bound` 상태가 되면 04 서비스 배포를 진행할 수 있다.

## 03-03.9 단계별 실행
```bash
make step-03-03-01-storageclass-assets-run
make step-03-03-01-storageclass-assets-verify
make step-03-03-02-storageclass-image-import-run
make step-03-03-02-storageclass-image-import-verify
make step-03-03-03-storageclass-apply-run
make step-03-03-03-storageclass-apply-verify
```

설명: `03-03` StorageClass는 `01` 반입, `02` 이미지 import, `03` manifest apply/동적 PVC 검증 순서로 실행한다. 각 세부 단계는 같은 번호의 verify를 갖는다.

참고: 원격 노드의 root volume이 작으면 이미지 tar 보관만으로도 `DiskPressure`가 발생할 수 있다. 기본값은 import 후 원격 tar를 삭제하며, 보존이 필요할 때만 `AIRGAP_KEEP_REMOTE_K8S_IMAGE_TARS=true`를 사용한다.

## 검증 결과
- `make 03-03-storageclass-run`: 성공
- `make 03-03-storageclass-verify`: 성공
- `kubectl get storageclass`: `local-path (default)`
- `local-path-provisioner`: `local-path-storage` namespace에서 `1/1 Running`
- 테스트 PVC/Pod: 동적 PV 생성, PVC `Bound`, volume 쓰기/읽기 성공
