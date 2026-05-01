# StorageClass 운영 매뉴얼

## 운영 기준
- 이번 과제의 기본 StorageClass는 `local-path-provisioner`로 구성한다.
- `local-path-provisioner`는 PVC 요청 시 PV를 자동 생성하지만, 실제 데이터는 선택된 노드의 로컬 디스크에 저장한다.
- local-path는 과제/실습용 기본 동적 프로비저닝으로 사용하고, 운영급 HA 스토리지로 설명하지 않는다.
- 실제 운영 환경에서는 요구사항에 따라 NFS provisioner, Longhorn, Rook-Ceph, 상용 SAN/NAS CSI Driver를 검토한다.

## 서비스 배포 전 확인
```bash
kubectl get storageclass
kubectl get pvc -A
kubectl get pv
```

설명: 기본 StorageClass가 없거나 PVC가 `Pending`이면 MySQL, MongoDB, Prometheus, Grafana 배포를 진행하지 않는다.

## local-path 사용 시 주의사항
- PV 데이터는 특정 노드 로컬 디스크에 저장된다.
- 노드 장애 시 해당 노드의 로컬 데이터에 접근할 수 없다.
- Pod가 다른 노드로 재스케줄링되면 기존 로컬 데이터와 분리될 수 있다.
- DB Pod는 무작정 재배치하지 않고, PV가 바인딩된 노드와 디스크 상태를 먼저 확인한다.
- 노드 디스크 용량 부족은 PVC 문제가 아니라 노드 파일시스템 문제로 나타날 수 있다.

## PVC 운영 원칙
- DB와 모니터링 서비스 PVC에는 `storageClassName`을 명시한다.
- 중요한 데이터 PVC의 삭제 정책은 운영 의도에 맞춰 `Retain` 또는 `Delete`를 확인한다.
- PVC 삭제 전에는 PV reclaim policy와 백업 여부를 확인한다.
- 서비스별 PVC 이름, namespace, 용량, storageClassName을 배포 기록에 남긴다.

## 백업 기준
- MySQL/MariaDB는 DB dump 또는 volume 백업 절차를 별도로 둔다.
- MongoDB는 `mongodump` 또는 volume 백업 절차를 별도로 둔다.
- Prometheus는 장기 보관이 필요하면 remote storage 또는 외부 백업을 검토한다.
- Grafana는 dashboard, datasource, admin secret을 별도 export 대상으로 둔다.

## 장애 점검
```bash
kubectl describe pvc -n <namespace> <pvc-name>
kubectl describe pv <pv-name>
kubectl get pods -A -o wide
kubectl describe pod -n <namespace> <pod-name>
df -h
```

설명: PVC가 `Pending`이면 StorageClass, provisioner Pod, PV 생성 이벤트를 확인한다. Pod가 `Pending`이면 PV node affinity와 Pod 스케줄링 위치를 함께 확인한다.

## 대안 선택 기준
| 요구사항 | 권장 방식 |
| --- | --- |
| 과제 검증, 단일 worker, 간단한 PVC 자동 생성 | local-path-provisioner |
| 여러 노드에서 같은 파일시스템 공유 | NFS provisioner |
| 노드 장애에도 스토리지 복제와 운영 기능 필요 | Longhorn 또는 Rook-Ceph |
| 기업 스토리지 장비 사용 | 벤더 CSI Driver |

## 운영 전환 기준
- 노드 장애 시 DB 데이터를 유지해야 하면 local-path만으로는 부족하다.
- 여러 worker에서 같은 볼륨을 읽고 써야 하면 local-path 대신 RWX 지원 스토리지를 사용한다.
- 운영 환경에서는 백업, 복구, 용량 증설, 장애 노드 교체 절차가 StorageClass 선택과 함께 확정돼야 한다.
