# 04-06. 서비스 통합 검증

## 실행
```bash
make 04-services-monitoring-verify
make 04-06-services-verify
```

## 검증 범위
- 서비스별 로컬 이미지 tar와 manifest 존재 여부
- worker 노드 containerd에 서비스 이미지 import 여부
- MariaDB, MongoDB, Prometheus StatefulSet Ready
- Grafana, Alloy Deployment rollout 완료
- MariaDB, MongoDB, Prometheus, Grafana PVC `Bound`
- 각 Service 객체 존재 여부

## 확인 명령
```bash
kubectl -n database get pods,pvc,svc -o wide
kubectl -n monitoring get pods,pvc,svc -o wide
kubectl get pv
```

## 완료 기준
- `database` namespace의 `mariadb-0`, `mongodb-0`이 `1/1 Running`이다.
- `monitoring` namespace의 `prometheus-0`, `grafana`, `alloy`가 `1/1 Running`이다.
- `data-mariadb-0`, `data-mongodb-0`, `data-prometheus-0`, `grafana-data` PVC가 모두 `Bound`이다.
