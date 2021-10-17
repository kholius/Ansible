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

#################################################################################################
            # Set Var
#################################################################################################

index_count_host=0
index_count_grp=0

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
    sudo apt install git -y 
    echo " ...Done "

    echo " Git Done. " > result_install_git.txt
    
    # Init Git
    sudo mkdir /etc/ansible_repos
    sudo chmod 755 /etc/ansible_repos 
    sudo mv /YAML-Ansible/ /etc/ansible_repos/
    sudo git init /etc/ansible_repos/

    sudo ll /etc/ | grep ansible_repos > result_create_repos.txt
    
    # prepare rapport
    rapport_install_git=$(cat result_install_git.txt)
    rapport_create_repos=$(result_create_repos.txt)



}

Create_and_Set_ssh(){
    echo " Let's prepare the SSH Service "
    # Install service ssh + restart It to enable
    echo " Install of ssh_server "
    sudo apt install open-ssh-server -y 
    echo " ...Done "
    sudo service sshd restart

    # Generation of RSA Key without Passphrase
    echo " Let's keygen "
    sudo ssh-keygen -t rsa -N "" 
    echo " ...Done "

    echo " "
    echo " "
    echo " "

    # Restart the service
    sudo service sshd status
    echo " "
    sudo service sshd restart
    echo " "
    sudo service sshd status
    echo " "
    echo " Ready to do id-copy "

    echo " "
    # Backup the sshd_config
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

Create_User_A_G(){

    echo " Let's create two user : "
    # Add user for Ansible
    echo " - khansible... "
    sudo useradd kholius
    echo kholius:kholius | chpasswd
    sudo useradd khansible
    echo khansible:kholius | chpasswd # This password NEED to be change
    sudo cat /etc/shadow | grep khansible
    echo "khansible ALL=(ALL:ALL) ALL" >> /etc/sudoers
    echo "kholius ALL=(ALL:ALL) ALL" >> /etc/sudoers

    echo "[...]"
    echo "      and         "
    echo "[...]"

    # Add user for git 
    echo " - giter... "
    sudo useradd giter
    echo giter:kholius | chpasswd # This password NEED to be change
    sudo cat /etc/shadow | grep giter
    echo "    ...Done      "

    # prepare rapport
    sudo cat /etc/shadow | grep khansible > user1.txt
    sudo cat /etc/shadow | grep giter > user2.txt

    rapport_user1=$(cat user1.txt)
    rapport_user2=$(cat user2.txt)

}

# 3 = ansible configuration [add_host + ssh_copy_id] + mk a rapport 

Ansible_Config_(){

    # the user want he use the pre conf? 
    read -p " Would you use the pre-conf settings? [y/n] " rep_preconf

    # If yes --action_for_it
    # If no --dew_it_himself
    if [[$rep_preconf -eq "y"]]
    then

        echo " Let's use the pre-config provide by Kholius... "
        
        echo ""
        echo ""
        echo ""

        echo " Let's do for hosts file"
        sudo cp ~/YAML-Ansible/hosts  /etc/ansible/
        echo " ...Done "
        
        echo ""
        echo ""
        echo ""

        echo " Transfert all of playbooks "
        sudo mkdir /etc/ansible/playbooks/
        sudo cp ~/YAML-Ansible/*.yaml /etc/ansible/playbooks/
        sudo ls /etc/ansible/playbooks/ | grep .yml
        echo " ...Done "

        echo " Pre-config provide by Kholius; done. " > result_ansible_conf.txt
        rapport_ansible_conf=$(cat result_ansible_conf.txt)
    
    
    
    elif [[$rep_preconf -eq "n"]]
    then
        echo " Well dew it yourself! UwU "

        echo " You can find all of file for config Ansible on : "
        sudo ls /etc/ | grep ansible

        echo " If you need to set the file where endpoints are declared, add them on : "
        sudo ls /etc/ansible/ | grep hosts

        echo " and if you need to set the file where playbooks are stored, add them on : "
        sudo ls /etc/ansible/ | grep playbooks

        echo " The general config is stored on"
        sudo ls /etc/ansible/ | grep ansible.cfg

        echo " Pre-config denied, the user must do configuration himself. (See docs) " > result_ansible_conf.txt
        rapport_ansible_conf=$(cat result_ansible_conf.txt)

    else
        echo " Something went wrong... "

    fi

    #read -p " Would you add some host to hosts file ? [ y/n ]"
    # if yes{
        #      how much ? = cb_host_to_add
        #       until $index_count_host -eq $cb_host_to_add
        #       {
                #    read -p " which host would you add ? " id_new_host
                #    read -p " already exist? " host_already_exist
                #    echo $id_new_host >> /etc/ansible/hosts
                #    if host_already_exist -eq yes
                     #  copy_id $id_new_host
        #       }
    #       }
    #           
    #read -p " Add a new grp? [ y/n ]" rep_add_grp
    # if $rep_add_grp -eq yes {
        #       read -p "how much ?" rep_cb_grp
        #       until $rep_cb_grp -eq $index_count_grp{
                #   read -p "wich name would you want ?" name_new_grp
                #   echo "[$name_new_grp]" >> /etc/ansible/hosts
        #       }
    #       }
    
}

mk_rapport(){
    # set var for date
    date > date.txt
    date_to_rapport=$(cat date.txt)
    # set var for whoami
    whoami > whoami.txt
    whoami_for_rapport=$(cat whoami.txt)
    #
    echo " Rapport Inbound..."
    echo ""
    echo ""
    echo " Well did you see the weather today? It's a good day for IT right? "
    echo ""
    sudo mkdir /etc/Rapports_/
    echo ""
    echo ""
    echo ""

    echo "###############################################################################################" >> /etc/Rapports_/rapport01.txt
    echo "###                               Rapport from Ansible Master                               ###" >> /etc/Rapports_/rapport01.txt
    echo "                     Done the:  $date_to_rapport        " >> /etc/Rapports_/rapport01.txt
    echo "###############################################################################################" >> /etc/Rapports_/rapport01.txt
    echo "###                                           |                                             ###" >> /etc/Rapports_/rapport01.txt
    echo "###   Hostname set : $rapport_change_hostnem  | Done by Administrator : $whoami_for_rapport "  >> /etc/Rapports_/rapport01.txt
    echo "###                                           |                                             ###"  >> /etc/Rapports_/rapport01.txt
    echo "###############################################################################################"  >> /etc/Rapports_/rapport01.txt
    echo "###############################################################################################" >> /etc/Rapports_/rapport01.txt
    echo "###____________________________________[NETWORK]____________________________________________###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                         ###" >> /etc/Rapports_/rapport01.txt
    echo "###_    Setting IP :  $rapport_change_ip                               "  >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                         ###" >> /etc/Rapports_/rapport01.txt
    echo "###_    Gateway :  $rapport_gtw_for_int                                 " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                         ###" >> /etc/Rapports_/rapport01.txt
    echo "###############################################################################################" >> /etc/Rapports_/rapport01.txt
    echo "###____________________________________[Bundle]____________________________________________###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###_     State of Install: $rapport_install_bundle                              " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "##############################################################################################" >> /etc/Rapports_/rapport01.txt
    echo "###_____________________________________[Ansible]__________________________________________###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###      State of Install: $rapport_install_ansible           " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###      State of Configuration : $rapport_ansible_conf       " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "##############################################################################################" >> /etc/Rapports_/rapport01.txt
    echo "###______________________________________[Git]_____________________________________________###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###      State of Install: $rapport_install_git                                            _" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###      Git repos: $rapport_create_repos              " >> /etc/Rapports_/rapport01.txt
    echo "###      Can be foundon : /etc/ansible_repos/          " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "##############################################################################################" >> /etc/Rapports_/rapport01.txt
    echo "###______________________________________[Ssh]_____________________________________________###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###   Package SSH: Open-ssh-server                            " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###   Status: $rapport_ssh_status                             " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###   Backup: $rapport_ssh_backup                             " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "##############################################################################################" >> /etc/Rapports_/rapport01.txt
    echo "###______________________________________[User]____________________________________________###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###          User for Ansible: $rapport_user1                     " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###          User for Git_Repos: $rapport_user2                   " >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "###                                                                                        ###" >> /etc/Rapports_/rapport01.txt
    echo "##############################################################################################" >> /etc/Rapports_/rapport01.txt

    # Part1 suppr .txt
    rm -f ~/result_change_ip.txt
    rm -f ~/result_gtw_for_int.txt
    rm -f ~/result_install_bundle.txt
    # Part2 suppr .txt
    rm -f ~/result_install_ansible.txt
    rm -f ~/result_install_git.txt
    rm -f ~/result_create_repos.txt
    rm -f ~/result_ssh_status.txt
    rm -f ~/result_backup_ssh.txt
    rm -f ~/user1.txt
    rm -f ~/user2.txt
    # Part3 suppr .txt
    rm -f ~/result_ansible_conf.txt
}

###############################################################################################
                # Set Upper Function
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

Set_Ansible_env(){
    echo "#######################################################################"
    echo "###########                    Part Two                    ############"
    echo "#######################################################################"

    install_ansible
    install_git
    Create_and_Set_ssh
    Create_User_A_G
    update_


}

Configuration(){
    Ansible_Config_
    mk_rapport
    echo " Right, you can find en Rapport in /etc/Rapports_/ "
    echo " Have a nice day "
}

bare
Set_Ansible_env
Configuration
