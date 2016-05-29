#!/bin/bash

#stanley-llc - boilerplate server template generator

#stdin
echo "Stanley LLC - Boilerplate Server Generator"

echo -n "Enter the name of your project: "
read projectName

echo -n "Enter the eventual website address you'd like to point to (no http or www): "
read website

echo -n "Enter the aws public address you'd like to point to: "
read publicAws

echo -n "Enter full GitHub SSH repo address (already created on GitHub.com) to clone: "
read gitHubRepo

#install nginx and nodejs
echo "INSTALLING NGINX..."
sudo yum install nginx
echo "INSTALLING NODEJS..."
sudo yum install nodejs npm --enablerepo=epel

#set git basics
sudo git config --global user.name "pdstanley"
sudo git config --global user.email "paul.daniel.stanley@gmail.com"

#create directories and set folders/files
sudo mkdir /var/www
overallFolder="/var/www"
projectFolder="$overallFolder/$projectName";
sudo mkdir -p "$projectFolder";
sudo mkdir -p "$overallFolder/deploy/$projectName";
deployFile="$overallFolder/deploy/$projectName/deploy.sh"

#set nginx server configuration file
nginxText="
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format  main  '\$remote_addr - \$remote_user [\$time_local] \"\$request\" '
                      '\$status \$body_bytes_sent \"\$http_referer\" '
                      '\"\$http_user_agent\" \"\$http_x_forwarded_for\"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 2048;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
    server_names_hash_bucket_size 64;

  server {
      listen       80;
      server_name  www.$website $website;

      location / {
          proxy_pass http://127.0.0.1:3000;
      }
  }

  server {
      listen       80;
      server_name  $publicAws;

      location / {
          proxy_pass http://127.0.0.1:8080;
      }
  }

}";
echo "$nginxText"| sudo tee "/etc/nginx/nginx.conf"

#set GitHub deploy webhook script
deployText="#!/bin/bash
cd /var/www/$projectName/ && git reset --hard HEAD && git pull
echo 'new project version deployed.'";
echo "$deployText"| sudo tee "$deployFile"

#generate ssh key and display
sudo ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
sudo chown -R ec2-user:ec2-user ~/.ssh
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

#read ssh key to console
echo $'\n\n'
cat ~/.ssh/id_rsa.pub | while read line
do
  echo "$line"
done
read -rsp $'\n\nCopy the above public key to "GitHub Account->Settings->SSH-GPG Keys" and press any key: \n' -n1 key

#install git and create new project
cd "$overallFolder/$projectName"
sudo chown -R ec2-user:ec2-user "$projectFolder"
git clone "$gitHubRepo" .
