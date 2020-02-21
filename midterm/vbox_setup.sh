#!/bin/bash

vbmg () { /mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe "$@"; }

NET_NAME="NETMIDTERM"
VM_NAME="A00938454"
SSH_PORT="12922"
WEB_PORT="12980"
SED_PROGRAM="/^Config file:/ { s/^.*:\s\+\(\S\+\)/\1/; s|\\\\|/|gp }"
VBOX_FILE=$(vbmg showvminfo "$VM_NAME" | sed -ne "$SED_PROGRAM")
VM_DIR=$(dirname "$VBOX_FILE")


clean_all(){
	vbmg natnetwork remove --netname $NET_NAME
	vbmg unregistervm "$VM_NAME" --delete
}

create_network(){
	    vbmg natnetwork add --netname "$NET_NAME" --network 192.168.10.0/24 --enable --dhcp off --port-forward-4 "SSH:tcp:[127.0.0.1]:"$SSH_PORT":[192.168.10.10]:22" --port-forward-4 "HTTP:tcp:[127.0.0.1]:"$WEB_PORT":[192.168.10.10]:80"
}


create_vm(){
	vbmg createvm --name "$VM_NAME" --ostype "RedHat_64" --register

	vbmg modifyvm "$VM_NAME" --cpus 1
	vbmg modifyvm "$VM_NAME" --memory 2048
	vbmg modifyvm "$VM_NAME" --audio "none"
	vbmg modifyvm "$VM_NAME" --nic1 natnetwork
	vbmg modifyvm "$VM_NAME" --nat-network1 "$NET_NAME"

	vbmg createmedium disk --filename "$VM_DIR/$VM_NAME".vdi --size 15000 --format VDI
	vbmg modifymedium disk "$VM_DIR/$VM_NAME".vdi --move "$VM_DIR"

	vbmg storagectl "$VM_NAME" --name "SATA Controller" --add "sata" --controller "IntelAhci"
	vbmg storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type "hdd" --medium "$VM_DIR/$VM_NAME".vdi

	vbmg storagectl "$VM_NAME" --name "IDE Controller" --add "ide" --controller "PIIX4"
	vbmg storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type "dvddrive" --medium "emptydrive"
}

start_vm(){
	vbmg startvm "$VM_NAME"
}

echo "Starting script..."

clean_all
create_network
create_vm
start_vm

echo "DONE!"
