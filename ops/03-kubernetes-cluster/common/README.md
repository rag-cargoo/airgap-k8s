# Common kubeadm Assets

- `manual-kubeadm/`과 `ansible-kubeadm/`이 같이 사용하는 공통 기준 자산을 둔다.
- 사전점검 스크립트, 공통 변수, 반입 경로 기준, bastion/control-node 접속 전제를 이 디렉토리에서 관리한다.
- 대상 환경이 바뀌면 여기서 주로 바꾸는 것은 다음 항목이다.
  - bastion 또는 control node SSH 접속 대상
  - master / worker IP
  - Ansible inventory와 SSH 옵션
  - ProxyCommand 또는 jump host 설정

## Directories
- `scripts/`
  - `kubeadm-preflight-check.sh`
