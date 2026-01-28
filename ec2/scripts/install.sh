#!/bin/bash
set -e

install_docker="yes"
install_awscli="yes"
install_postgresql="yes"
install_nginx="yes"


# Update system
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required packages
echo "Installing required packages..."
sudo apt-get install -y apt-transport-https ca-certificates curl unzip git


echo "Installing Docker..."
if [[ "$install_docker" != "no" ]]; then
    sudo apt-get install -y docker.io docker-buildx
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker ubuntu
    # newgrp docker
    echo "✅ Docker installed"
else
    echo "⏩ Skipping Docker installation"
fi

# ------------------------
# Install AWS CLI v2
# ------------------------
echo "Installing AWS CLI v2..."
if [[ "$install_awscli" != "no" ]]; then
    cd /tmp || exit 1
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo unzip awscliv2.zip
    sudo ./aws/install
    sudo rm -rf aws awscliv2.zip
    echo "✅ AWS CLI v2 installed"
else
    echo "⏩ Skipping AWS CLI installation"
fi

# ------------------------
# Install PostgreSQL
# ------------------------
echo "Installing PostgreSQL..."
if [[ "$install_postgresql" != "no" ]]; then  
  cd /tmp || exit 1
  sudo apt-get -y install postgresql
  sudo apt install postgresql-client postgresql-client-common libpq-dev
  sudo systemctl enable postgresql
  sudo systemctl start postgresql
  echo "✅ PostgreSQL installed"
else
  echo "⏩ Skipping PostgreSQL installation"
fi

# sudo -i -u postgres
# psql


# ------------------------
# Install Nginx
# ------------------------
echo "Installing Nginx..."
if [[ "$install_nginx" != "no" ]]; then
  sudo apt-get -y install nginx
  sudo systemctl enable nginx
  sudo systemctl start nginx
  echo "✅ Nginx installed"
else
  echo "⏩ Skipping Nginx installation"
fi

DATABASE=testdb
USER=ec2user
PASSWORD=koti21


sudo -u postgres psql
CREATE DATABASE testdb;
CREATE USER ec2user with encrypted PASSWORD 'koti21';
grant all privileges on database testdb to ec2user;

# -----------------------------------------
# Mount the ebs volume to a file system
sudo mkfs -t ext4 /dev/nvme1n1
sudo mkdir -p /mnt/data
sudo mount /dev/nvme1n1 /mnt/data

# Make the volume persistent
UUID=$(sudo blkid -s UUID -o value /dev/nvme1n1) && echo "UUID=$UUID /mnt/data ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab

# Attach the postgresql data directory to the ebs volume
sudo systemctl stop postgresql
sudo mkdir -p /mnt/data/postgresql/16
sudo chown -R postgres:postgres /mnt/data/postgresql
sudo chmod 700 /mnt/data/postgresql
sudo rsync -av /var/lib/postgresql/16/main/ /mnt/data/postgresql/16/main/
sudo mv /var/lib/postgresql/16/main /var/lib/postgresql/16/main.old

# ------- Edit the postgresql configuration files ---------
sudo nano /etc/postgresql/16/main/postgresql.conf # change the data directory to /mnt/data/postgresql/16/main
# listen_addresses = '*'

sudo nano /etc/postgresql/16/main/pg_hba.conf

# host    all    all    0.0.0.0/0   md5
# host    all    all    ::/0        md5
sudo systemctl start postgresql

cat > ~/.pgpass << 'EOF'
localhost:5432:testdb:ec2user:koti21
EOF
chmod 600 ~/.pgpass

chmod +x /tmp/scripts/s3_backup.sh

sudo mkdir -p /mnt/data/backups
sudo chown ubuntu:ubuntu /mnt/data/backups

crontab -e #then append this line 
0 */6 * * * /tmp/scripts/s3_backup.sh >> /mnt/data/backups/s3_backup.log 2>&1 # run every 6 hours

find /mnt/data/backups -type f -mtime +7 -delete

# ---------------PG Restore----------------
aws s3 cp s3://your-bucket/backup-pg-20251229_105001Z.pgdump /home/ubuntu/
pg_restore -h localhost -p 5432 -U ec2user -d testdb /home/ubuntu/backup-pg-20251229_105001Z.pgdump

# ---------------Docker persistent setup----------------
sudo systemctl stop docker

sudo mkdir -p /mnt/data/docker
sudo chown -R ubuntu:ubuntu /mnt/data/docker
sudo chmod 711 /mnt/data/docker

sudo rsync -aP /var/lib/docker/ /mnt/data/docker/
sudo mv /var/lib/docker /var/lib/docker.old

sudo nano /etc/docker/daemon.json

{
  "data-root": "/mnt/data/docker"
}

# ------------------ECR Login and Run----------------
aws ecr get-login-password --region ap-south-2 | docker login --username AWS --password-stdin 208940303379.dkr.ecr.ap-south-2.amazonaws.com
docker pull 208940303379.dkr.ecr.ap-south-2.amazonaws.com/cafe:v1.0.0

docker run -d -p 8080:8080 --env-file .env --name cafe --network host 208940303379.dkr.ecr.ap-south-2.amazonaws.com/cafe:v1.0.1