# Ansible kubeadm

- 수동 kubeadm 절차를 Ansible playbook으로 자동화한다.
- Ansible은 외부 인터넷 다운로드가 아니라 오프라인 자산 복사, 패키지 설치, kubeadm init/join 실행을 담당한다.
- 공통 사전점검과 반입 경로 기준은 `../common/`을 따른다.
- bastion 또는 폐쇄망 내부 control node에서 SSH가 가능하면 같은 playbook을 재사용할 수 있어야 한다.
- 환경이 바뀌면 주로 inventory, host IP, SSH user, private key, ProxyCommand 설정만 변경한다.
