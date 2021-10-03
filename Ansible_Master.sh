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
}
ip_fix(){
    sudo apt install net-tools -y 
    ip a
    read -p "" int_
    read -p "" ip_
    read -p "" msk_
    read -p "" gtw_
    read -p "" nemsrv_
    read -p "" sts


}
bundle(){

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
}