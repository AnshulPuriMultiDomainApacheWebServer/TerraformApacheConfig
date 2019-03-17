#!/bin/bash
sudo apt-get update -y
# Install Apache2 Web Server
sudo apt-get install apache2 -y
# Install Python pip
sudo apt install python-pip -y
# Install AWS CLI
sudo pip install awscli
sudo su
sudo chmod -R 755 /var/www
cd /var/www
# Create directories to configure apache for name-based virtual hosting
sudo mkdir -p /var/www/test.com
sudo mkdir -p /var/www/test2.com
sudo echo "hello test" > /var/www/test.com/index.html
sudo echo "hello test2" > /var/www/test2.com/index.html
cd /etc/apache2/sites-available
# Copy over the conf files to configure apache for name-based virtual hosting, for the two domains
sudo aws s3 cp s3://${s3_bucket_ec2userdatafiles}/www.test.com.conf /etc/apache2/sites-available/www.test.com.conf
sudo aws s3 cp s3://${s3_bucket_ec2userdatafiles}/ww2.test.com.conf /etc/apache2/sites-available/ww2.test.com.conf
# Enable the two sites
sudo a2ensite www.test.com.conf
sudo service apache2 reload
sudo a2ensite ww2.test.com.conf
sudo service apache2 reload
sudo service apache2 restart
# Capture the userdata log output in S3 for trouble-shooting
internalhostname=`curl http://169.254.169.254/latest/meta-data/local-hostname`
sudo aws s3 cp /var/log/cloud-init-output.log s3://${s3_bucket_ec2userdatafiles}/"$internalhostname"_cloud-init-output.log
sudo aws s3 cp /var/log/cloud-init.log s3://${s3_bucket_ec2userdatafiles}/"$internalhostname"_cloud-init.log