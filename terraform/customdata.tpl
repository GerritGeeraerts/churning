#!/bin/bash

# Update and install necessary packages
sudo apt-get update -y && sudo apt-get install -y \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg-agent \
  software-properties-common \
  python3-pip

# Install Docker
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" -y
#sudo apt-get update -y
#sudo apt-get install docker-ce docker-ce-cli containerd.io -y
#sudo usermod -aG docker ubuntu


# Install MLflow
sudo pip3 install mlflow

mkdir "/home/adminuser/log"
mkdir "/home/adminuser/log/mlflow"

# Create a systemd service for MLflow UI
cat <<EOF | sudo tee /etc/systemd/system/mlflow.service
[Unit]
Description=MLflow UI
After=network.target

[Service]
User=adminuser
WorkingDirectory=/home/adminuser
StandardOutput=file:/home/adminuser/log/mlflow/mlflow.log
StandardError=file:/home/adminuser/log/mlflow/error.log
ExecStart=/usr/local/bin/mlflow ui --host 0.0.0.0 --port 5000

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable the MLflow service
sudo systemctl daemon-reload
sudo systemctl enable mlflow.service
sudo systemctl start mlflow.service
sudo systemctl status mlflow.service