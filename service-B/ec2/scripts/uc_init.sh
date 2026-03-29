#!/bin/bash

IFS=',' read -ra NODES <<< "$1"

echo "일단 대기 100s"
sleep 100

FIRST=true
for NODE in "${NODES[@]}"; do
    if [ "$FIRST" = true ]; then
        uc machine init -i ~/.ssh/ec2-keypair.pem ubuntu@$NODE
        FIRST=false

        echo "cluster 초기화 대기중 100s..."
        sleep 100
    else
        uc machine add -i ~/.ssh/ec2-keypair.pem ubuntu@$NODE
    fi
done