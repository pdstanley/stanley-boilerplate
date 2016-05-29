#!/bin/bash

#stanley-llc - boilerplate server generator

echo "Stanley LLC - Boilerplate Server Generator"

echo -n "Enter the name of your project: "
read projectName

echo -n "Enter the eventual website address you'd like to point it to (no http or www): "
read website

echo -n "Enter the aws public address you'd like to point it to: "
read publicAws

echo -n "Enter full GitHub repo address (already created on GitHub.com) for new project: "
read gitHubRepo

#install nginx and nodejs
sudo yum install nginx
sudo yum install nodejs npm --enablerepo=epel

sudo mkdir /var/www
overallFolder="/var/www"

sudo mkdir -p "$overallFolder/$projectName";
sudo mkdir -p "$overallFolder/deploy/$projectName";
deployFile="$overallFolder/deploy/$projectName/deploy.sh"

deployText="
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
# sudo sh -c 'echo "text" >>/file.txt'
echo "$deployText" > "deploytemp.sh"
sudo cp -R "deploytemp.sh" "$deployFile"

nginxText="#!/bin/bash
cd /var/www/$projectName/ && git reset --hard HEAD && git pull
echo ’new project version deployed.'";
#sudo sh -c 'echo "$nginxText" > "/etc/nginx/nginx.conf"'
#echo "$nginxText" > "/etc/nginx/nginx.conf"
echo "$nginxText" > "nginx.conf"
sudo cp -R "nginx.conf" "/etc/nginx/nginx.conf"

cd "$overallFolder/$projectName"

#install git and create new project
#sudo git clone origin-url . "https://github.com/pdstanley/modernowner.git"
# git init
# git remote add origin "git@github.com:pdstanley/$gitHubRepo.git"
#
# git reset --mixed origin/master
# git add .
# git commit -m "first commit"
#git push origin master

#generate ssh key and display
# sudo -Hu ec2-user ssh-keygen -t rsa -N -f ~/.ssh/id_rsa
sudo ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

cat ~/.ssh/id_rsa.pub | while read line
do
  echo "$line"
done
