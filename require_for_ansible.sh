#!/bin/bash

###################################
# Script pour set les services pour Ansible
# Ce Script est dédié au seting coté Endpoint
#               2/2               #
###################################


# install packages std

# Fonction des updates
update_sys() {
    sudo apt update -y
    sudo apt list --upgradable
    sudo apt upgrade -y
}

# recupération des scripts
#git clone git+ssh://giter@192.168.1.150/home/giter/tr/

add_user_ansible() {
    # var add user pour ansible 
    name_ansible_user="khansible"
    pwd_ansible_user="kholius"

    cat /etc/shadow | grep $name_ansible_user > uz.txt
    # création de l'utilisateur khansible
    echo "Création de kholius for Ansible: Khansible"
    sudo useradd $name_ansible_user
    sudo cat /etc/shadow | grep $name_ansible_user

    # Modification du MDP de $name_ansible_user 
    echo "$name_ansible_user:$pwd_ansible_user" | sudo chpasswd
    sudo cat /etc/shadow | grep $name_ansible_user

}

update_sys
add_user_ansible
update_sys
