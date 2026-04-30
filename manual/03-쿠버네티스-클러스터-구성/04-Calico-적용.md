# 03-04. Calico 적용 기준

## 대응 경로
- `ops/03-kubernetes-cluster/calico/`

## 기준
- CNI는 `Calico`로 확정한다.
- 오프라인 자산에는 Calico manifest를 포함한다.
- 수동 설치와 Ansible 설치 모두 `05-calico` 단계에서 같은 CNI 기준을 사용한다.

## 참고
- 과제 원문에 남아 있는 `Calico 또는 Flannel` 표기는 `manual/00-제출-매뉴얼-개요/01-과제-원문.md` 원문 보존 목적이다.
- 현재 운영 기준 문서와 실행 경로는 모두 `Calico` 기준으로 본다.
