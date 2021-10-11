#!/bin/bash

###################################################
#           Script for an Ansible_Master 
###################################################

echo "##############################################################"
echo "#                Wellcome to Ansible_Master Script            "
echo "##############################################################"
echo "                                                              "
echo "                                                              "
echo "                                                              "
echo "This script has been create by :Kholius                       "
echo "Be sure to be root or have the good right to execute this script"
echo "This machine must be connect to internet for a good config. Thx."
echo "                             2/2                               "


echo " for now, it's work only with apt!"


# 3 part
# 1 = bare setup : update + hostname + ifconfig/netplan + bundle_install [vim, cockpit, ]
# 2 = install classique ansible + create user khansible + update + ssh [install; create key] + git [install, create user giter, and mkdir a repos for all script]
# 3 = ansible configuration [add_host + ssh_copy_id] + mk a rapport 




##################################################################################################
            # Set Under_Function
#################################################################################################

# 1 = bare setup : update + hostname + ifconfig/netplan + bundle_install [vim, cockpit, ]

update_(){
    sudo apt update -y && sudo apt upgrade -y 
}

gst_hostnem(){
    read -p "Wich Hostname would you set ?" hostnem
    echo $hostnem
    $hostnem > /etc/hostname
    cat /etc/hostname
    # prepare rapport
    rapport_change_hostnem=$(cat /etc/hostname)
}

# Set IP fix
ip_fix(){
    
    # Display Info
    sudo apt install net-tools -y 
    ifconfig -s 
    # Set var with Questions
    echo " Well, it's time to set up your Network Interface " 
    echo "[ Take care how your input done ]"
    read -p " Wich Interface would you set ? : " int_
    read -p " and Wich IP? : " ip_
    read -p " well and wich netmask? [no CIDR]" msk_
    read -p " Ok, all packet will pass by wich door [GTW]" gtw_
    read -p " hmmm... have you a DNS? " nemsrv_
    read -p " I suppose this Int will be up however I question you : " status_

    # Display ALL conf Int and Routes
    ifconfig -s
    route
    # Setting IP fix and Add route
    ifconfig -v $int_ $ip_ netmask $msk_ $status_ # ifconfig  -v ens33 192.168.1.199 netmask 255.255.255.0 up
    route add $gtw_ $int # route add default 192.168.1.240 ens33
    # Get Output for Rapport
    ifconfig $int_ | grep inet > result_change_ip.txt
    route | grep $int > result_gtw_for_int.txt
    # Print Result to User
    echo " Change Apply... "
    route | grep $int_
    ifconfig $int_
    echo " ...Done "

    # prepare rapport
    rapport_change_ip=$(cat result_change_ip.txt)
    rapport_gtw_for_int=$(cat result_gtw_for_int.txt)

}

bundle(){
    echo " Install Bundle..."
    sudo apt install vim -y
    sudo apt install screenfetch -y
    sudo apt install cockpit -y
    sudo apt install ufw -y
    sudo apt install open-ssh-server -y 
    sudo apt install nmap -y 
    update_
    echo " ...Done "
    
    echo " Bundle Done. " > result_install_bundle.txt
    # prepare rapport
    rapport_install_bundle=$(cat result_install_bundle.txt)

}

# 2 = install classique ansible + create user khansible + update + ssh [install; create key] + git [install, create user giter, and mkdir a repos for all script]

install_ansible(){

    echo
    echo
    echo

    echo " Install Ansible... "
    sudo apt install ansible -y 
    echo " ...Done "

    echo " Ansible Done. " > result_install_ansible.txt
    # prepare rapport
    rapport_install_ansible=$(cat result_install_ansible.txt)

}

install_git(){
     
    # Install Git
    echo " Install Git... "
    sudo apt install Git -y 
    echo " ...Done "

    echo " Git Done. " > result_install_git.txt
    
    # Init Git
    sudo mkdir /etc/ansible_repos
    sudo chmod 755 /etc/ansible_repos 
    git init /etc/ansible_repos/
    ll /etc/ | grep ansible_repos > result_create_repos.txt
    
    # prepare rapport
    rapport_install_git=$(cat result_install_git.txt)
    rapport_create_repos=$(result_create_repos.txt)



}

Create_and_Set_ssh(){
    echo " Let's prepare the SSH Service "

    echo " Install of ssh_server "
    sudo apt install open-ssh-server -y 
    echo " ...Done "
    sudo service sshd restart

    echo " Let's keygen "
    ssh-keygen -t rsa -N "" 
    echo " ...Done "

    echo " "
    echo " "
    echo " "

    sudo service sshd status
    sudo service sshd restart
    sudo service sshd status

    echo " Ready to do id-copy "


    echo " here, we save the SSH_conf "
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
    ls /etc/ssh/ | grep sshd_config.bak > result_backup_ssh.txt
    if [[result_backup_ssh.txt == $NULL]]
    then
        echo " So, there is not backup about your ssh.service, be ensure to make all needed for protect your configuration. "
        echo " So, there is not backup about your ssh.service, be ensure to make all needed for protect your configuration. " > result_backup_ssh.txt
    fi

    # prepare rapport
    sudo service sshd status | grep ssh.service > result_ssh_status.txt 
    sudo service sshd status | grep Active >> result_ssh_status.txt 

    rapport_ssh_status=$(cat result_ssh_status.txt)
    rapport_ssh_backup=$(cat result_backup_ssh.txt)
}

Create_User_AG(){

    echo " Let's create two user : "
    echo " - khansible... "
    sudo useradd khansible
    echo khansible:kholius | chpasswd # This password NEED to be change
    cat /etc/shadow | grep khansible

    echo "[...]"
    echo "      and         "
    echo "[...]"

    echo " - giter... "
    sudo useradd giter
    echo giter:kholius | chpasswd # This password NEED to be change
    cat /etc/shadow | grep giter
    echo "    ...Done      "

    # prepare rapport
    cat /etc/shadow | grep khansible > user1.txt
    cat /etc/shadow | grep giter > user2.txt

    rapport_user1=$(cat user1.txt)
    rapport_user2=$(cat user2.txt)

}

###############################################################################################

bare(){

    echo "#######################################################################"
    echo "###########                    Part One                    ############"
    echo "#######################################################################"

    # Updates
    update_
    # Hostname
    gst_hostnem
    # Gestion ifconfig
    ip_fix
    # Bundle
    bundle
    # Updates
    update_

}

Set_Ansible(){
    echo "#######################################################################"
    echo "###########                    Part Two                    ############"
    echo "#######################################################################"

}


bare