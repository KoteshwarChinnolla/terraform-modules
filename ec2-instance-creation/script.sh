#!/bin/bash
set -e

# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
sudo apt-get install -y apt-transport-https ca-certificates curl unzip git

# ------------------------
# Install Docker
# ------------------------
read -p "Do you want Docker to be installed? (yes/no): " install_docker
if [[ "$install_docker" != "no" ]]; then
    sudo apt-get install -y docker.io docker-buildx
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker ubuntu
    newgrp docker
    echo "✅ Docker installed"
else
    echo "⏩ Skipping Docker installation"
fi

# ------------------------
# Install kubectl
# ------------------------
read -p "Do you want to install kubectl? (yes/no): " install_kubectl
if [[ "$install_kubectl" != "no" ]]; then
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
    sudo apt-get update
    sudo apt-get install -y kubectl
    echo "✅ kubectl installed"
else
    echo "⏩ Skipping kubectl installation"
fi

# ------------------------
# Install kind
# ------------------------
read -p "Do you want to install kind? (yes/no): " install_kind
if [[ "$install_kind" != "no" ]]; then
    curl -Lo ./kind "https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64"
    chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
    echo "✅ kind installed"
else
    echo "⏩ Skipping kind installation"
fi

# ------------------------
# Install AWS CLI v2
# ------------------------
read -p "Do you want to install AWS CLI v2? (yes/no): " install_awscli
if [[ "$install_awscli" != "no" ]]; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
    echo "✅ AWS CLI v2 installed"
else
    echo "⏩ Skipping AWS CLI installation"
fi

read -p "Do ypu want to install helm? (yes/no): " install_helm
if [[ "$install_helm" != "no" ]]; then
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    echo "✅ Helm installed"
else

read -p "Do you want to install helm? (yes/no): " isthio_install
if [[ "$isthio_install" != "no" ]]; then
    curl -L https://istio.io/downloadIstio | sh -
    export PATH="$PATH:/home/ubuntu/istio-1.27.0/bin"
    echo "✅ isthio installed"
else

# ------------------------
# Print versions (if installed)
# ------------------------
echo "🔍 Checking installed versions..."
command -v docker && docker --version || echo "Docker not installed"
command -v kubectl && kubectl version --client || echo "kubectl not installed"
command -v kind && kind --version || echo "kind not installed"
command -v aws && aws --version || echo "AWS CLI not installed"
git --version


##################################
#########External Storage#########
##################################
sudo mkfs -t ext4 /dev/xvdbf   # making file system for mounted volume
sudo mkdir -p /mnt/runner # creating sub directry uner mount
sudo mount /dev/xvdbf /mnt/runner # mounting our route to it


# to save from restarts
sudo blkid /dev/xvdbf # copy  Uuid from here
sudo nano /etc/fstab
# replace uuid from from the one you compied and add it to the last line
UUID=1234abcd-5678-90ef-1234-567890abcdef   /mnt/runner   ext4   defaults,nofail   0   2

# creat the some directry in mount to store our system files to
mkdir /mnt/runner/backend

#move that file to the mounted directry
sudo mv ~/backend-runner/actions-runner/_work /mnt/runner/backend/_work

# sync for future changes
ln -s /mnt/runner/backend/_work ~/backend-runner/actions-runner/_work

