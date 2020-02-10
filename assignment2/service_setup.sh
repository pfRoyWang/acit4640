#!/bin/bash

vbmg () { /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@"; }

NET_NAME="4640"
VM_NAME="VM4640"
SSH_PORT="12022"
WEB_PORT="12080"
SED_PROGRAM="/^Config file:/ { s/^.*:\s\+\(\S\+\)/\1/; s|\\\\|/|gp }"
VBOX_FILE=$(vbmg showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
VM_DIR=$(dirname "$VBOX_FILE")
PXE_VM="PXE4640"


clean_all(){
	vbmg natnetwork remove --netname "$NET_NAME"
	vbmg unregistervm "$VM_NAME" --delete
}

create_network(){
	    vbmg natnetwork add --netname "$NET_NAME" --network 192.168.230.0/24 --enable --dhcp ioff --port-forward-4 "SSH:tcp:[127.0.0.1]:"$SSH_PORT":[192.168.230.10]:22" --port-forward-4 "HTTP:tcp:[127.0.0.1]:"$WEB_PORT":[192.168.230.10]:80" --port-forward-4 "SSH2:tcp:[127.0.0.1]:12222:[192.168.230.200]:22"
}


create_vm(){
	vbmg createvm --name "$VM_NAME" --ostype "RedHat_64" --register

	vbmg modifyvm "$VM_NAME" --cpus 1
	vbmg modifyvm "$VM_NAME" --memory 2480
	vbmg modifyvm "$VM_NAME" --audio "none"
	vbmg modifyvm "$VM_NAME" --nic1 natnetwork
	vbmg modifyvm "$VM_NAME" --nat-network1 "$NET_NAME"
	vbmg modifyvm "$VM_NAME" --boot1 disk --boot2 net --boot3 none --boot4 none

	vboxmanage registervm /mnt/c/users/pfroy.DESKTOP-2BKREVS/'VirtualBox VMs'/PXE4640/PXE4640.vbox
	vbmg modifyvm "$PXE_VM" -nicl natnetwork
	vbmg modifyvm "$PXE_VM" --nat-network2 "$NET_NAME"

	vbmg createmedium disk --filename "$VM_NAME".vdi --size 10000 --format VDI 

	vbmg storagectl "$VM_NAME" --name "SATA Controller" --add "sata" --controller "IntelAhci" 
	vbmg storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type "hdd" --medium "$VM_DIR/$VM_NAME".vdi

	vbmg storagectl "$VM_NAME" --name "IDE Controller" --add "ide" --controller "PIIX4"
	vbmg storageattach "$VM_NAME" --storagectl "IDE Controller" --port 1 --device 0 --type "dvddrive" --medium "emptydrive"
}

start_vm(){
	vbmg startvm "$PXE_VM" 

	while /bin/true; do 
	ssh -i acit_admin_id_rsa -p 12222 \
	      	    -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
		    -q admin@localhost exit
	if [ $? -ne 0 ]; then
	 		echo "PXE server is not up, sleeping..."
			sleep 2
	else
		break
	fi
	done
}

send_files(){
	echo "sending the required files"
	
	sudo scp -i acit_admin_id_rsa -P 12222 -r setup/ admin@localhost:~
	ssh -i acit_admin_id_rsa -p 12222\
	    -o ConnectTimeout=2 -o StrictHostKeyChecking=no \
	    -q admin@localhost sudo mv /home/admin/setup /var/www/lighttpd/files/
}


echo "Starting script..."

clean_all
create_network
create_vm
start_vm
send_files

echo "DONE!"
