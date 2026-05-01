# Manifests

- `local-path-storage.yaml`는 `01-03` 오프라인 자산 다운로드 단계에서 `assets/offline-assets/kubernetes/manifests/` 아래에 생성한다.
- 원본 기준은 `rancher/local-path-provisioner` release `v0.0.35`의 `deploy/local-path-storage.yaml`이다.
- 폐쇄망 실행을 위해 provisioner와 helper pod 이미지는 명시적 registry/tag로 고정한다.
