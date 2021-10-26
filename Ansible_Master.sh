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
echo "                          ###                                "



# 3 part
# 1 = bare setup : update + hostname + ifconfig/netplan + bundle_install [vim, cockpit, ]
# 2 = install classique ansible + create user khansible + update + ssh [install; create key] + git [install, create user giter, and mkdir a repos for all script]
# 3 = ansible configurattxtn [add_host + ssh_copy_id] + mk a rapport 

#################################################################################################
            # Set Var
#################################################################################################

index_count_host=0
index_count_grp=0
internet_stat=99

##################################################################################################
            # Set Under_Functtxtn
#################################################################################################

# 0 Verify OS (for choose between $os_package_manger and yum) + check Internet conncttxtn
# Openning

# Check Internet
check_internet(){

    # ping test with 5 request 
    echo " Checking Internet "
    ping 8.8.8.8 -c 5
    echo $?
    # the ping's result make a statement 0 = Ok ; 1 = Error ; OOBE 
    if [[ $? -eq 0 ]]
    then
        echo " Your Internet access is OK "
        internet_stat=0
        echo $internet_stat

    elif [[ $? -eq 1 ]]
    then
        echo " Your Internet access is Down "
        echo " The script will be stop "
        internet_stat=100
        echo $internet_stat
    else
     echo "[[ OOBE ]]"
     internet_stat=50
    fi

    # take acttxtn if there is no internet connextxtn or OOBE
    if [[ $internet_stat -eq 100 ]]
    then
        echo " WARNING, No Internet Connextxtn "
        echo " Script will go down "
        sleep 10

        # exit from script
        exit

    elif [[ $internet_stat -eq 50 ]]
        echo " OOBE "
        echo " Reboot Inbound "
        sleep 8

        # reboot
        reboot

    else
    fi

}

# Package Manager
check_os_package_manager(){
    
    # get os_based ID and manipulate string 
    cat /etc/os-release | grep NAME= -m 1
    cat /etc/os-release | grep NAME= -m 1 > os.txt
    sed -i "s/ID_LIKE=//g" os.txt
    sed -i 's/"//g' os.txt
    
    #cat os.txt content in a var
    os_distrib=$((cat os.txt))

    # set the os_package_manger
    if [[ $os_distrib="UBUNTU" ]]
    then

        os_package_manger="apt"

    elif [[ $os_distrib="Debian GNU/Linux" ]]
    then

        os_package_manger="apt"

    elif [[ $os_distrib="VMware Photon OS" ]]
    then
        
        os_package_manger="yum"

    elif [[ $os_distrib="Fedora" ]]
    then
    
        os_package_manger="yum"

    elif [[ $os_distrib="Oracle Linux Server" ]]
    then
    
        os_package_manger="yum"

    elif [[ $os_distrib="Red Hat Enterprise Linux" ]]
    then

        os_package_manger="yum"
    
    elif [[ $os_distrib="Rocky Linux" ]]
    then

        os_package_manger="yum"
    
    else

    fi

}


# 1 = bare setup : update + hostname + ifconfig/netplan + bundle_install [vim, cockpit, ]

# Do updates
update_(){
    sudo $os_package_manger update -y && sudo $os_package_manger upgrade -y 
}

# verificattxtn of returns displayed after last acttxtn (use for install bundle)
verif_return(){
    # If the last command return 1 there was a problem
    echo $?
    if [[ $?=1]]
    then
        echo " Something went wrong... "
        $index_install=$(($index_install+1))

    # If the last command return 0 is OK
    elif [[$?=0]]
    then
        echo " Good. "
        $index_install=$(($index_install+0))
    else
    fi
}

# setting hostname
gst_hostnem(){
    read -p "Wich Hostname would you set ?" hostnem
    echo $hostnem
    echo $hostnem > /etc/hostname
    cat /etc/hostname
    # prepare rapport
    rapport_change_hostnem=$(cat /etc/hostname)
}

# Set IP fix
ip_fix_info(){
    
    # Display Info
    sudo $os_package_manger install net-tools -y 
    ifconfig -s 
    # Set var with Questtxtns
    echo " Well, it's time to set up your Network Interface " 
    echo "[ Take care how your input done ]"
    read -p " Wich Interface would you set ? : " int_
    read -p " and Wich IP? : " ip_
    read -p " well and wich netmask? [no CIDR]" msk_
    read -p " Ok, all packet will pass by wich door [GTW]" gtw_
    read -p " Have you a DNS? " nemsrv_
    read -p " Wich status $int_ must have ? [ up / down ] " status_


    # Loop for status_
    # up or down  - Ok
    # empty or other - by default Up
    if [[ $status_ = "up" ]]
    then
    echo " UP "

    elif [[ $status_ = "down" ]]
    then
    echo " Down "

    elif  [[ -z $status_ ]]
    then
    echo " Default status: Up "
    status_="up"

    else
    echo " Default status: Up "
    status_="up"

    fi

}
# Apply IP six
ip_fix_apply(){
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

    # counter about install of bundle
    index_install=0

    # Install bundle with controle with verif_return functtxtn 
    echo " Install Bundle..."
    sudo $os_package_manger install vim -y
    verif_return
    sudo $os_package_manger install screenfetch -y
    verif_return
    sudo $os_package_manger install cockpit -y
    verif_return
    sudo $os_package_manger install ufw -y
    verif_return
    sudo $os_package_manger install open-ssh-server -y 
    sudo $os_package_manger install nmap -y 
    verif_return
    update_
    echo " ...Done "
    


    # Loop for prepare result_install_bundle.txt
    # If $index = 0 everything is OK else there is a problem 
    if [[ $index_install -eq 0 ]]
    then
        echo " Bundle Done. " > result_install_bundle.txt
    elif [[ $index_install -gt 0 ]]
    then
        echo " Bundle Done, but something maybe wrong... " > result_install_bundle.txt
    else
        echo " OOBE "
    fi

    # prepare rapport
    rapport_install_bundle=$(cat result_install_bundle.txt)

}

# 2 = install classique ansible + create user khansible + update + ssh [install; create key] + git [install, create user giter, and mkdir a repos for all script]

install_ansible(){

    echo " "
    echo " "
    echo " "
    update_
    $os_package_manger search ansible | grep ansible
    if [[ $? -eq 0 ]]
    then
        echo " Install Ansible... "
        sudo $os_package_manger install ansible -y
        echo " Ansible Done. " > result_install_ansible.txt
        sudo $os_package_manger install ansible-doc -y 
        sleep 5
        echo " Everything looking good "
        sleep 5
        echo " ...Done "

    else
        echo " "
        echo " OOBE - repository doesn't available "
    fi
    # prepare rapport
    rapport_install_ansible=$(cat result_install_ansible.txt)

}

install_git(){
     
    # Install Git
    echo " Install Git... "
    sudo $os_package_manger install git -y 
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
    sudo $os_package_manger install open-ssh-server -y 
    echo " ...Done "
    sudo service sshd restart

    # Generattxtn of RSA Key without Passphrase
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
        echo " So, there is not backup about your ssh.service, be ensure to make all needed for protect your configurattxtn. "
        echo " So, there is not backup about your ssh.service, be ensure to make all needed for protect your configurattxtn. " > result_backup_ssh.txt
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

# 3 = ansible configurattxtn [add_host + ssh_copy_id] + mk a rapport

Ansible_Config_(){

    # the user want he use the pre conf? 
    read -p " Would you use the pre-conf settings? [y/n] " rep_preconf

    # If yes --acttxtn_for_it
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

        echo " Pre-config denied, the user must do configurattxtn himself. (See docs) " > result_ansible_conf.txt
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
    ip_fix_apply
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
    echo "###      State of Configurattxtn : $rapport_ansible_conf       " >> /etc/Rapports_/rapport01.txt
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

    sleep 5

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
                # Set Upper Functtxtn
###############################################################################################

starter(){

    # basic verification
    check_internet
    check_os_package_manager

}

bare(){

    echo "#######################################################################"
    echo "###########                    Part One                    ############"
    echo "#######################################################################"

    # Check Internet Access
    check_internet

    # Check wich package manager will be used
    check_os_package_manager

    # Updates
    update_
    # Hostname
    gst_hostnem
    # Gesttxtn ifconfig
    ip_fix_info
    # Bundle
    bundle

    sleep 5
    # Updates
    update_

}

Set_Ansible_env(){
    echo "#######################################################################"
    echo "###########                    Part Two                    ############"
    echo "#######################################################################"
    sleep 5
    install_ansible
    install_git
    Create_and_Set_ssh
    Create_User_A_G
    sleep 5
    update_


}

Configurattxtn(){
    Ansible_Config_
    mk_rapport


    echo " Right, you can find en Rapport in /etc/Rapports_/ "
    echo " Have a nice day "
    echo " Provide by Kholius "
    sleep 5
    ip_fix_apply
}

scriptounet(){

    starter

    if [[$internet_stat -eq 0]]
    then

        bare
        Set_Ansible_env
        Configurattxtn
    
    elif [[$internet_stat -eq 99]]
    then 

        echo " Ok but take care about your Internet connection..."
        check_internet
        bare
        Set_Ansible_env
        Configurattxtn

    else

        echo " We've got a situation here "
        exit

    fi


    
}




scriptounet