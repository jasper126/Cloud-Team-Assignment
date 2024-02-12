#!/bin/bash
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent

#Python 3 installation
sudo dnf -y install python3
sudo yum -y install python3-pip
pip install mysql-connector-python

#install webserver
sudo yum -y install httpd
sudo systemctl start httpd
sudo systemctl enable httpd

#MySQL installation 
sudo dnf -y install mariadb105