# 서버 구축 테스트 과제문

## 주제
- 온프레미스(폐쇄망 = Air-gapped) Kubernetes 및 모니터링 서비스 구축 및 활용

## 환경
- 인터넷이 불가능한 네트워크 환경
- 리눅스 기본 구성

## 사용자 및 네트워크 설정
- `devops` 사용자를 생성하고 `sudo` 권한을 부여한다.
- 호스트 이름을 `k8s-master`, `k8s-worker1`로 설정한다.
- `/etc/hosts`에 각 노드 IP와 이름을 등록한다.

## Kubernetes 클러스터 구성
- `master + worker` 구성
- 네트워크 플러그인: `Calico` 또는 `Flannel`

## 서비스 배포 및 모니터링 설정
- `MySQL` 또는 `MariaDB`
- `MongoDB`
- `Prometheus`
- `Grafana`
- `Grafana Alloy`
- `Prometheus` + `Grafana` 외부 접근 설정

## 제출물
- 서버 구축 과정에 대한 상세한 단계별 매뉴얼 작성본
- 서버 구축 설정에 사용된 파일 압축본(`ZIP`, `7z` 등)
