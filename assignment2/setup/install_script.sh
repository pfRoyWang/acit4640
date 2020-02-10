#!/bin/bash

sudo firewall-cmd --zone=public --add-port=8080/tcp
sudo firewall-cmd --zone=public --list-all

sudo useradd todoapp -p 'P@ssw0rd'
sudo usermod -a -G wheel todoapp

sudo yum install -y git
sudo yum install -y nodejs
sudo yum install -y npm
sudo yum install -y mongodb-server
sudo systemctl enable mongod 
sudo systemctl start mongod

sudo mkdir /home/todoapp/app
sudo chown todoapp /home/todoapp
sudo git clone https://github.com/timoguic/ACIT4640-todo-app.git /home/todoapp/app/ACIT4640-todo-app      
sudo chmod 755 /home/todoapp                                                     


sudo cd /home/todoapp/app/ACIT4640-todo-app
sudo npm install --prefix /home/todoapp/app/ACIT4640-todo-app
sudo mv /home/admin/setup/database.js /home/todoapp/app/ACIT4640-todo-app/config

sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo mv /home/admin/setup/nginx.conf /etc/nginx/
sudo systemctl restart nginx

sudo mv /home/admin/setup/todoapp.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl start todoapp
sudo systemctl enable todoapp

sudo systemctl restart nginx

