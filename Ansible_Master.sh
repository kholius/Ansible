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

# 0 Verify OS (for choose between $os_package_manager and yum) + check Internet conncttxtn
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
        echo " Ping -OK "
        echo " Let's try a HTTPS request "
        icmp_stat=0
        echo $icmp_stat > icmp_result.txt

        if nc -zw1 google.com 443
        then
            
            https_stat=0
            echo " Your Internet access is OK "
            internet_stat=0
            echo $internet_stat
            echo $https_stat > https_result.txt

        else

            https_stat=1
            echo " HTTPS request failed "
            internet_stat=100
            echo $https_stat > https_result.txt

        fi

    elif [[ $? -eq 1 ]]
    then

        echo " Your Internet access is unusual "
        internet_stat=100
        echo $internet_stat
        icmp_stat=1
        echo $icmp_stat > icmp_result.txt

        echo " Maybe ICMP:8 is denied... "
        echo " Right, let's try a HTTPS request "
        if nc -zw1 google.com 443
        then
            
            echo " Your Internet access is OK "
            https_stat=0
            internet_stat=0
            echo $internet_stat
            echo $https_stat > https_result.txt
        
        else

            https_stat=1
            echo " HTTPS request failed "
            echo $https_stat > https_result.txt
            internet_stat=100
            
        fi
    else

     echo "[[ OOBE ]]"
     internet_stat=50
     icmp_stat=2
     https_stat=2

    echo $icmp_stat > icmp_result.txt
    echo $https_stat > https_result.txt
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
    then
        echo " OOBE "
        echo " Reboot Inbound "
        sleep 8

        # reboot
        reboot

    else
    
    echo " OOBE "
    fi

    https_rapport=$(cat https_result.txt)
    icmp_rapport=$(cat icmp_result.txt)


}

# Package Manager
check_os_package_manager(){
    
    # get os_based ID and manipulate string 
    # os-release is available on every distib
    # lsb-release isn't available on RPM based OS 

    cat /etc/os-release | grep NAME= -m 1
    cat /etc/os-release | grep NAME= -m 1 > os.txt
    sed -i "s/NAME=//g" os.txt
    sed -i 's/"//g' os.txt

    #cat /etc/lsb-release | grep DISTRIB_ID= -m 1
    #cat /etc/lsb-release | grep DISTRIB_ID= -m 1 > os.txt
    #sed -i "s/DISTRIB_ID=//g" os.txt
    #sed -i 's/"//g' os.txt
    
    #cat os.txt content in a var
    os_distrib=$(cat os.txt)
    echo $os_distrib

    # set the os_package_manager
    if [[ $os_distrib=="UBUNTU" ]]
    then

        os_package_manager1="apt"

    elif [[ $os_distrib=="Debian GNU/Linux" ]]
    then

        os_package_manager1="apt"

    elif [[ $os_distrib="VMware Photon OS" ]]
    then
        
        os_package_manager1="yum"

    elif [[ $os_distrib=="Fedora" ]]
    then
    
        os_package_manager1="yum"

    elif [[ $os_distrib=="Oracle Linux Server" ]]
    then
    
        os_package_manager1="yum"

    elif [[ $os_distrib=="Red Hat Enterprise Linux" ]]
    then

        os_package_manager1="yum"
    
    elif [[ $os_distrib=="Rocky Linux" ]]
    then

        os_package_manager1="yum"
    
    else

    echo " OOBE Package "

    fi

    echo $os_package_manager1
    echo $os_package_manager1 > usable_os_package_manager.txt


}


# 1 = bare setup : update + hostname + ifconfig/netplan + bundle_install [vim, cockpit, ]

# Do updates
update_(){
    sudo $os_package_manager update -y && sudo $os_package_manager upgrade -y 
}

# verificattxtn of returns displayed after last acttxtn (use for install bundle)

verif_return(){
    # If the last command return 1 there was a problem
    echo $? >> r1.txt
    if [[ $r1 -eq '1' ]]
    then
        echo " Something went wrong... "
        index_install=$(($index_install+1))
        echo $index_install


    # If the last command return 0 is OK
    elif [[ $r1 -eq '0' ]]
    then
        echo " Good. "
        let index_install=$(($index_install+0))
        echo $index_install

    else
        echo "OOBE"
    fi

    rm -rf ~/r1.txt

}
# setting hostname
gst_hostnem(){
    read -p "Wich Hostname would you set ?" hostnem
    echo $hostnem
    # echo $hostnem > /etc/hostname
    # cat /etc/hostname
    # prepare rapport
    # rapport_change_hostnem=$(cat /etc/hostname)
    hostnameclt -set-hostname $hostnem

        # verificattxtn of returns displayed after last acttxtn (use for install bundle)
        verif_return_hostname(){
            # If the last command return 1 there was a problem
            echo $? >> r2.txt
            if [[ $? -eq 1 ]]
            then

                echo " Something went wrong..."
                echo " $hostnem can not be apply "
                echo " [ Retry later ]"

            # If the last command return 0 is OK
            elif [[$? -eq 0 ]]
            then
                echo " Good. "
                echo " [ $hostnem applied ] "
                echo " [ a reboot will be needed at the end ]"
            else
                echo " OOBE Hostname "
            fi

            rm -rf ~/r2.txt

        }

    verif_return_hostname

}

# Set IP fix
ip_fix_info(){
    
    # Display Info
    # sudo $os_package_manager install net-tools -y 
    # ifconfig -s 
    ip addr
    ip route

    # Set var with Questtxtns
    echo " Well, it's time to set up your Network Interface " 
    echo "[ Take care how your input done ]"
    read -p " Wich Interface would you set ? : " int_
    read -p " and Wich IP? : " ip_
    read -p " well and your netmask? [CIDR]" msk_
    read -p " By wich gateway [GTW]" gtw_
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
    # ifconfig -s
    # route
    ip addr | grep $int_
    ip route

    # Setting IP fix and Add route
    # ifconfig -v $int_ $ip_ netmask $msk_ $status_ # ifconfig  -v ens33 192.168.1.199 netmask 255.255.255.0 up
    # route add $gtw_ $int # route add default 192.168.1.240 ens33
    ip link set $int_ $status_ # set the status 
    ip addr add $ip_/$msk_ dev $int_ # apply IP addr/cidr on a nic
    ip route add $gtw_/$msk_ dev $int # apply GTW on a nic
        
    echo "
    
    
    
    
    
        "
    sleep 10
    # Get Output for Rapport
    # ifconfig $int_ | grep inet > result_change_ip.txt
    # route | grep $int > result_gtw_for_int.txt
    ip addr | grep inet > result_change_ip.txt
    ip route | grep $int_ > result_gtw_for_int.txt

    # Print Result to User
    sleep 5
    ip addr | grep $int_ 
    ip route
    echo " Change Apply... "
    # route | grep $int_
    sleep 5
    # ifconfig $int_
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
    sudo $os_package_manager install vim -y
    verif_return
    sudo $os_package_manager install screenfetch -y
    verif_return
    sudo $os_package_manager install cockpit -y
    verif_return
    sudo $os_package_manager install ufw -y
    verif_return
    sudo $os_package_manager install open-ssh-server -y 
    sudo $os_package_manager install nmap -y 
    verif_return
    sudo $os_package_manager install sshpass -y 
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
        echo " OOBE bundle "
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
    $os_package_manager search ansible | grep ansible
    if [[ $? -eq 0 ]]
    then
        echo " Install Ansible... "
        sudo $os_package_manager install ansible -y
        echo " Ansible Done. " > result_install_ansible.txt
        sudo $os_package_manager install ansible-doc -y 
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
    sudo $os_package_manager install git -y 
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
    sudo $os_package_manager install open-ssh-server -y 
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
    if [[ result_backup_ssh.txt == $NULL ]]
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

    ls /etc/sudoers.d | grep sudoers_ansible > if_file_sudoers_ansible_exist.txt
    if_file_sudoers_exist=$(cat if_file_sudoers_ansible_exist.txt)

    if [[ -f $if_file_sudoers_exist ]]
    then
        touch /etc/sudoers.d/sudoers_ansible

    elif [[ $if_file_sudoers_exist == "sudoers_ansible" ]]
    then
        echo " OK "
    else
        echo "Forcing Inbound..."
        touch /etc/sudoers.d/sudoers_ansible



    # mkdir /etc/sudoers.d/sudoers_ansible
    echo "khansible ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/sudoers_ansible
    echo "kholius ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/sudoers_ansible

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

     rm -rf ~/if_file_sudoers_ansible_exist.txt

}

# 3 = ansible configurattxtn [add_host + ssh_copy_id] + mk a rapport

Ansible_Config_(){

    # the user want he use the pre conf? 
    read -p " Would you use the pre-conf settings? [y/n] " rep_preconf

    # If yes --acttxtn_for_it
    # If no --dew_it_himself
    if [[ $rep_preconf -eq "y" ]]
    then

        echo " Let's use the pre-config provide by Kholius... "
        sleep 3
        echo ""
        echo ""
        echo ""
        sleep 3
        echo " Let's do for hosts file"
        sudo cp ~/YAML-Ansible/hosts  /etc/ansible/
        echo " ...Done "
        sleep 3
        echo ""
        echo ""
        echo ""
        sleep 3
        echo " Transfert all of playbooks "
        sudo mkdir /etc/ansible/playbooks/
        sudo cp ~/YAML-Ansible/*.yaml /etc/ansible/playbooks/
        sudo ls /etc/ansible/playbooks/ | grep .yml
        echo " ...Done "
        sleep 1
        echo " Pre-config provide by Kholius; done. " > result_ansible_conf.txt
        rapport_ansible_conf=$(cat result_ansible_conf.txt)
    
    
    
    elif [[ $rep_preconf -eq "n" ]]
    then
        echo " Well dew it yourself! UwU "
        sleep 5
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
    sleep 5
    echo " Well did you see the weather today? It's a good day for IT right? "
    echo ""
    sleep 5
    sudo mkdir /etc/Rapports_/
    echo ""
    echo ""
    echo ""

    echo "###############################################################################################
          ###                               Rapport from Ansible Master                               ###
          ###            Done the:  $date_to_rapport        
          ###############################################################################################
          ###                                           |                                             ###
          ###   Hostname set : $rapport_change_hostnem  | Done by Administrator : $whoami_for_rapport 
          ###                                           |                                            
          ###############################################################################################
          ###############################################################################################
          ###____________________________________[NETWORK]____________________________________________###
          ###                                                                                         ###
          ###_    Setting IP :  $rapport_change_ip                               
          ###                                                                                         ###
          ###_    Gateway :  $rapport_gtw_for_int                                 
          ###                                                                                         ###
          ###_    Protocols:  [ 0 -ok / 1 -ko ]  
          ###           - ICMP: $icmp_stat
          ###           - HTTPS: $https_stat   
          ###                                                                                         ###
          ###############################################################################################
          ###____________________________________[Bundle]_____________________________________________###
          ###
          ###_     State of Install: $rapport_install_bundle                              
          ###                                                                                        ###
          ###                                                                                        ###
          ##############################################################################################
          ###_____________________________________[Ansible]__________________________________________###
          ###                                                                                        ###
          ###      State of Install: $rapport_install_ansible           
          ###                                                                                        ###
          ###      State of Configurattxtn : $rapport_ansible_conf       
          ###                                                                                        ###
          ##############################################################################################
          ###______________________________________[Git]_____________________________________________###
          ###                                                                                        ###
          ###      State of Install: $rapport_install_git                                            
          ###                                                                                        
          ###      Git repos: $rapport_create_repos              
          ###
          ###      Can be foundon : /etc/ansible_repos/         
          ###                                                                                        ###
          ##############################################################################################
          ###______________________________________[Ssh]_____________________________________________###
          ###                                                                                        ###
          ###   Package SSH: Open-ssh-server                            
          ###                                                                                        
          ###   Status: $rapport_ssh_status                           
          ###                                                                                        
          ###   Backup: $rapport_ssh_backup                             
          ###                                                                                        ###
          ##############################################################################################
          ###______________________________________[User]____________________________________________###
          ###                                                                                        ###
          ###                                                                                        ###
          ###          User for Ansible: $rapport_user1                    
          ###                                                                                        
          ###          User for Git_Repos: $rapport_user2                  
          ###                                                                                        ###
          ###                                                                                        ###
          ###                                                                                        ###
          ##############################################################################################" >> /etc/Rapports_/rapport01.txt

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
    rm -f ~/icmp_result.txt
    rm -f ~/https_result.txt

}

###############################################################################################
                # Set Upper Functtxtn
###############################################################################################

starter(){

    # basic checking
    # internet
    check_internet
    # OS package mgmt
    check_os_package_manager
    os_package_manager=$(cat usable_os_package_manager.txt)
    echo $os_package_manager
    rm -rf usable_os_package_manager.txt

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

    if [[ $internet_stat -eq 0 ]]
    then

        bare
        Set_Ansible_env
        Configurattxtn
    
    elif [[ $internet_stat -eq 99 ]]
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







# Add a verification in check_internet ------------- OK
    # if nc -zw1 google.com 443; then
    # echo OK

# for OS checking   ---------------- OK 
    # watch lsb_release
    # os-release is available in every distrib lsb no!

# hostname setting ------------------- OK 
    # hostnameclt set-hostname $hostnem

# for ip by ifconfig ---------------------- OK // test Inbound
    # use more Ip than ifconfig

# setting SUDOERS -----------------------------OK // test Inbound
    # create another file "mysudoers" and add this file in sudoers.d
    # Keep SUDOERS clean.

# Install without Internet
    # in case of the server hasn't an internet connnexion, 
    # see for keep somewhere every bin of all app
    # https://www.linux.com/news/how-install-packages-source-linux/
