#!/bin/bash

SYSTEM_DIR=/etc/systemd/system
NGINX_DIR=/etc/nginx

sudo scp -i ~/.ssh/midterm_id_rsa -P 12922 nginx.conf midterm@localhost:~
sudo scp -i ~/.ssh/midterm_id_rsa -P 12922 hichat.service midterm@localhost:~

ssh -i ~/.ssh/midterm_id_rsa -p 12922 -t midterm@localhost <<EOF
	sudo yum install git -y;
	sudo yum install nodejs -y;
	sudo yum install npm -y;

	mkdir /app
	if grep "hichat" /etc/passwd >/dev/null 2>&1;then
		echo "hichat user already existed"
	else
		sudo useradd -m -d /app hichat
		sudo passwd hichat disabled
	fi

	sudo yum install nginx -y
	sudo systemctl enable nginx
	sudo systemctl start nginx

       	sudo mv ~/nginx.conf $NGINX_DIR

        sudo mv ~/hichat.service $SYSTEM_DIR

	sudo chmod 755 /app
	echo "Start Cloning"
	cd /app
       	sudo git clone https://github.com/wayou/HiChat.git
	cd /app/HiChat
	sudo npm install
        

	sudo systemctl restart nginx
	sudo systemctl daemon-reload
	sudo systemctl enable hichat
	sudo systemctl start hichat	
EOF

