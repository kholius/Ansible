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


# Choose your part 
# a = all 
# 1 = bare setup : update + hostname + ifconfig/netplan + bundle_install [vim, cockpit, ]
# 2 = install classique ansible + create user khansible + update + ssh [install; create key] + git [install, create user giter, and mkdir a repos for all script]
# 3 = ansible configuration [add_host + ssh_copy_id]




##################################################################################################
            # Set Under_Function
#################################################################################################
update(){
    sudo apt update -y && sudo apt upgrade -y 
}

gst_hostnem(){
    read -p "Wich Hostname would you set ?" hostnem
    echo $hostnem
    $hostnem > /etc/hostname
    cat /etc/hostname
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
    sudo apt update -y
    sudo apt upgrade -y
    echo " Bundle Done. "
}



###############################################################################################

bare(){
    
    # Updates
    update
    # Hostname
    gst_hostnem
    # Gestion ifconfig
    ip_fix
    # Bundle
    bundle
}

bare