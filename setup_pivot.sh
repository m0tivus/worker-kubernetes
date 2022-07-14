# Copyright (c) 2021 Oracle and/or its affiliates.
#!/bin/bash
# All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl
# setup_bastion_orderstep.sh
#
# Purpose: The following script helps autoconfiguring a Bastion environment for Orderstep

echo "[0/13] Setting up .bashrc aliases"
sudo tee -a ~/.bashrc > /dev/null <<'EOF'
export WORKON_HOME=~/envs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS=' -p /usr/bin/python3 '
source /usr/local/bin/virtualenvwrapper.sh
export PATH="/home/ubuntu/Terraform-Docs":"/home/ubuntu/Terraform":${PATH}
alias ocibe="cd ~/REPOS/OCIBE"
alias ocife="cd ~/REPOS/OCIFE"
alias k="kubectl"
alias tfversion='f(){ cd ~/Terraform ; unzip -oqq terraform_"$@"_linux_arm64.zip ; cd - ; terraform -version unset -f f; }; f'
EOF
echo -e "[0/13] Done.\n\n"

echo "[1/13] Preparing things"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo -e "[1/13] Done.\n\n"

echo "[2/13] Installing OCI CLI"
sudo runuser -l ubuntu -c 'mkdir -p ~/oci_cli'
sudo runuser -l ubuntu -c 'wget https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh'
sudo runuser -l ubuntu -c 'chmod +x install.sh'
sudo runuser -l ubuntu -c '~/install.sh --install-dir ~/oci_cli/lib/oracle-cli --exec-dir ~/oci_cli/bin --accept-all-defaults'
echo -e "[2/13] Done.\n\n"

echo "[3/13] Initializing OCI CLI config"
sudo mkdir -p ~/.oci
sudo tee -a ~/.oci/config > /dev/null <<'EOF'
[DEFAULT]
user=
fingerprint=
tenancy=
region=
key_file=
EOF
sudo chown ubuntu:ubuntu -R ~/.oci
sudo chmod 0600  ~/.oci/config

sudo runuser -l ubuntu -c 'oci setup repair-file-permissions --file ~/.oci/config'
echo -e "[3/13] Done.\n\n"

echo "[4/13] Installing Python, Docker and other needed 3rd parties"
sudo apt-get -y update
sudo apt-get -y install ca-certificates curl gnupg lsb-release unzip jq
sudo apt-get -y install python3 python3-pip
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose
echo -e "[4/13] Done.\n\n"

echo "[5/13] Configure Docker"
sudo usermod -a -G docker $USER
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo chmod 666 /var/run/docker.sock
echo -e "[5/13] Done.\n\n"

echo "[6/13] Installing Python PIP and extra modules"
sudo pip3 install virtualenv
sudo pip3 install virtualenvwrapper
echo -e "[6/13] Done.\n\n"

echo "[7/13] Initializing AWS credentials"
sudo mkdir -p ~/.aws
sudo tee -a ~/.aws/credentials > /dev/null <<'EOF'
[default]
aws_access_key_id=
aws_secret_access_key=
EOF
sudo chown ubuntu:ubuntu -R ~/.aws
sudo chmod 0600  ~/.aws/credentials
echo -e "[7/13] Done.\n\n"

echo "[8/13] Installing kubectl"
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl
echo -e "[8/13] Done.\n\n"

echo "[9/13] Installing K9s"
mkdir -p ~/k9s_installer
wget https://github.com/derailed/k9s/releases/download/v0.25.18/k9s_Linux_arm64.tar.gz -P ~/k9s_installer
tar -xvf ~/k9s_installer/k9* -C ~/k9s_installer
sudo cp ~/k9s_installer/k9s /usr/bin
rm -rf ~/k9s_installer
echo -e "[9/13] Done.\n\n"

echo "[10/13] Create hosting directories"
mkdir -p ~/REPOS/OCIFE
mkdir -p ~/REPOS/OCIBE
mkdir -p ~/Terraform
mkdir -p ~/.ssh/OCI_KEYS/API
mkdir -p ~/.ssh/OCI_KEYS/SSH
echo -e "[10/13] Done.\n\n"

echo "[11/13] Download and Install Terraform latest stable release and Terraform Docs"
mkdir -p ~/Terraform
sudo runuser -l ubuntu -c 'wget $(echo "https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_linux_arm64.zip") -P ~/Terraform'
sudo runuser -l ubuntu -c 'unzip ~/Terraform/* -d ~/Terraform'

mkdir -p ~/Terraform-Docs
sudo runuser -l ubuntu -c 'cd ~/Terraform-Docs; wget $(echo "https://github.com/terraform-docs/terraform-docs/releases/download/v$(curl -s https://github.com/terraform-docs/terraform-docs/releases/latest |cut -d 'v' -f 2 | cut -d \"  -f 1)/terraform-docs-v$(curl -s https://github.com/terraform-docs/terraform-docs/releases/latest |cut -d 'v' -f 2 | cut -d \"  -f 1)-linux-arm64.tar.gz ")' 
sudo runuser -l ubuntu -c 'cd ~/Terraform-Docs; tar -xvf terraform-docs-v$(curl -s https://github.com/terraform-docs/terraform-docs/releases/latest |cut -d 'v' -f 2 | cut -d \"  -f 1)-linux-arm64.tar.gz'
echo -e "[11/13] Done.\n\n"

echo "[12/13] Fixing Terminal watch for VSCode"
echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
echo "[12/13] Done"

echo "[13/13] Rebooting terminal"
exec -l $SHELL
echo -e "[13/13] Done.\n\n"