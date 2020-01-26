#!/bin/bash
cd setup
sudo apt-get install sshpass -y

sshpass -p "P@ssw0rd" scp nginx.conf admin:~
sshpass -p "P@ssw0rd" scp todoapp.service admin:~  

sshpass -p "P@ssw0rd" ssh admin <<EOF
	echo "P@ssw0rd" | sudo -S yum install git -y;
	sudo yum install nodejs -y;
	sudo yum install npm -y;
	sudo yum install mongodb-server -y;
	sudo systemctl enable mongod;
	sudo systemctl start mongod;
	if grep "todoapp" /etc/passwd >/dev/null 2>&1;then
		echo "todoapp user already existed"
	else
		sudo useradd todoapp
		sudo passwd todoapp P@ssw0rd
	fi

	sudo yum install nginx -y
	sudo systemctl enable nginx
	sudo systemctl start nginx

	if [ ! -f /etc/nginx/nginx.service ]; then
        	sudo mv ~/nginx.conf /etc/nginx/
	else
		sudo rm /etc/nginx/nginx.conf
		sudo mv ~/nginx.conf /etc/nginx/
	fi

        if [ ! -f /etc/systemd/system/todoapp.service ]; then
                sudo mv ~/todoapp.service /etc/systemd/system/
        else
                sudo rm /etc/systemd/system/todoapp.service
                sudo mv ~/todoapp.service /etc/systemd/system/
        fi

	sudo chmod 755 /home/todoapp
	echo "P@ssw0rd" | sudo -S su - todoapp;
	if [ -d "/home/todoapp/ACIT4640-todo-app" ] || [ -d "/home/todoapp/app" ]; then
                echo "App folder existed, continue to execute the command"
		cd /home/todoapp/app
		sudo npm install
      	else	
		cd /home/todoapp
                sudo git clone https://github.com/timoguic/ACIT4640-todo-app.git
             	sudo mv ACIT4640-todo-app app
		cd /home/todoapp/app
		sudo npm install
        fi
	sudo systemctl restart nginx
	sudo systemctl daemon-reload
	sudo systemctl enable todoapp
	sudo systemctl start todoapp	
EOF

