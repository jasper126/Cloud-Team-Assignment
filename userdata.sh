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
cd /var/www/html/
# Create a simple HTML file
echo '<!DOCTYPE html>' > index.html
echo '<html lang="en">' >> index.html
echo '<head>' >> index.html
echo '    <meta charset="UTF-8">' >> index.html
echo '    <meta name="viewport" content="width=device-width, initial-scale=1.0">' >> index.html
echo '    <title>Hello, CloudTeam!</title>' >> index.html
echo '</head>' >> index.html
echo '<body>' >> index.html
echo '    <h1>Hello, CloudTeam!</h1>' >> index.html
echo '    <p>This is a simple HTML page served by Apache HTTP Server on Amazon Linux.</p>' >> index.html
echo '</body>' >> index.html
echo '</html>' >> index.html
sudo service httpd restart

#MySQL installation 
sudo dnf -y install mariadb105
