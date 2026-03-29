#!/bin/bash
set -e

# OS 감지
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "지원되지 않는 OS입니다."
    exit 1
fi

if [ "$OS" == "amzn" ]; then
    echo "Amazon Linux 감지됨"
    sudo yum update -y
    sudo yum install docker -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -a -G docker ec2-user

elif [ "$OS" == "ubuntu" ]; then
    echo "Ubuntu 감지됨"
    
    # 기존 Docker 관련 패키지 제거 (충돌 방지)
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
        sudo apt-get remove -y $pkg 2>/dev/null || true
    done
    
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl gnupg
    
    # 키링 디렉토리 생성
    sudo install -m 0755 -d /etc/apt/keyrings
    
    # 기존 키 파일이 있으면 삭제
    sudo rm -f /etc/apt/keyrings/docker.gpg
    
    # Docker GPG 키 추가 (--batch --yes로 interactive prompt 방지)
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    
    # VERSION_CODENAME 사용 (lsb_release 대신 - /etc/os-release에서 이미 sourcing됨)
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${VERSION_CODENAME} stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -a -G docker ubuntu

else
    echo "지원되지 않는 OS입니다: $OS"
    exit 1
fi

# Docker Compose standalone 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 버전 확인
docker --version
docker-compose --version
