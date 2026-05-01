# StorageClass Operation Runbook

## Purpose
- 04 서비스 배포 전 StorageClass와 PVC 상태를 확인한다.
- local-path 기반 PV가 어느 노드에 묶였는지 확인한다.
- PVC/PV 장애가 서비스 배포 문제인지 스토리지 문제인지 분리한다.

## Daily Checks
```bash
kubectl get storageclass
kubectl get pvc -A
kubectl get pv
kubectl get pods -A -o wide
```

## PVC Pending Check
```bash
kubectl describe pvc -n <namespace> <pvc-name>
kubectl get pods -n local-path-storage -o wide
kubectl logs -n local-path-storage deploy/local-path-provisioner
```

## Bound PV Location Check
```bash
kubectl describe pv <pv-name>
kubectl get pod -n <namespace> <pod-name> -o wide
```

## Node Disk Check
```bash
df -h
sudo du -sh /opt/local-path-provisioner 2>/dev/null || true
```

## Guardrails
- Do not delete PVC/PV before checking reclaim policy and backup state.
- Do not move DB Pods across nodes before checking PV node binding.
- Treat local-path as a lab/default dynamic provisioner, not HA storage.
- Use NFS, Longhorn, Rook-Ceph, or a vendor CSI driver for production-grade storage requirements.
