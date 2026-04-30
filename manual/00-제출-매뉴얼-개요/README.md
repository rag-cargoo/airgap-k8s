# 00. 제출 매뉴얼 개요

## 0.1. 과제 주제
- 온프레미스(폐쇄망 = Air-gapped) Kubernetes 및 모니터링 서비스 구축 및 활용

## 0.2. 구축 범위
- 인터넷이 불가능한 네트워크 환경과 리눅스 기본 구성을 확인한다.
- `01` 장의 환경 재현은 AWS Terraform 또는 VM 방식으로 설명할 수 있다.
- `devops` 사용자, sudo 권한, hostname, `/etc/hosts`를 설정한다.
- `master + worker` Kubernetes 클러스터를 구성한다.
- CNI는 `Calico`를 적용한다.
- `MySQL(or MariaDB)`, `MongoDB`, `Prometheus`, `Grafana`, `Grafana Alloy`를 배포한다.
- `Prometheus`와 `Grafana` 외부 접근을 설정한다.
- `02` 장 이후 실제 설치 절차는 VM 기준으로 진행한다.

## 0.3. 버전 기준
- Kubernetes 버전은 `v1.35.3`으로 고정한다.
- `kubeadm`, `kubelet`, `kubectl`은 모두 `v1.35.3` 기준으로 맞춘다.
- container runtime은 `containerd`를 기본 기준으로 한다.
- CNI는 `Calico`로 고정한다.
- 서비스 이미지 버전은 오프라인 반입 가능성과 호환성을 확인한 뒤 각 서비스 장에서 확정한다.

## 0.4. 사전 조사 템플릿
- 실제 실행 전 접속 경로, bastion/control node 유무, SSH 방식, 노드 IP, 수동/Ansible 선택 기준은 `03-사전-조사-정보-수집-템플릿.example.yaml` 기준으로 먼저 정리한다.
- 실제 값은 `03-사전-조사-정보-수집-템플릿.yaml`에 작성하고, 이 파일은 Git에 올리지 않는다.

## 0.5. 매뉴얼 목차
1. `00-제출-매뉴얼-개요/`
2. `01-인터넷-불가능-네트워크-환경-및-리눅스-기본-구성/`
3. `02-사용자-및-네트워크-설정/`
4. `03-쿠버네티스-클러스터-구성/`
5. `04-서비스-배포-및-모니터링-설정/`
6. `05-프로메테우스-그라파나-외부-접근-설정/`
7. `06-제출/`

## 0.6. 제출 형식
- 원본은 Markdown으로 작성한다.
- 최종 제출 시 Word, HWP, PPT, PDF 중 요구 형식으로 변환한다.
- 설정 파일 압축본에는 실제 사용한 manifest, values, Ansible playbook, 설정 파일만 포함한다.
