#!/bin/bash







################################################ Function ######################################################################################

# This function explain th why of what about this script
context(){
    echo "########################################################################## "
    echo " Provide by Kholius                                                        "
    date
    cat /etc/os-release | grep NAME
    echo "#  "
    echo "# Your on my host administrator,                                           "
    echo "# You must be root or a user with administrator right.                     "
    echo "# Here you may choose between multiple choice,                             "
    echo "# you'll can create/destroy some groups, host and send ssh-key to this host"
    echo "# 1: Add Group / 2: Add Host / 3: Del Group / 4: Del Host"
}

Add_Host(){
    i=0
    echo " Information about new Host "
    read -p " How much: "cb_host
    

    until [ $i -eq $cb_host]
    do
        read -p " Name Host: "name_host
        read -p " ID Host [IP or Name]: "id_host
        #read -p " Who is the user for Ansible? "ansible_user
        ansible_user="khansible"


        echo " $name_host will be add to host... "
        echo "$id_host    $name_host" >> /etc/ansible/hosts
        $?
        cat /etc/ansible/hosts | grep "$name_host"
        cat /etc/ansible/hosts | grep "$id_host"
        $?
        if [[ $? -eq 0]]
        then
            echo " Host added. "
            ping 8.8.8.8 -c 3
            echo $?
            if [[ $? -eq 0]]
            then
                echo " Copy ssh-key to $name_host: "
                ssh-copy-id $ansible_user@$id_host
            fi
        fi
    done

}

Add_Group(){
    # How much ? cb_grp
    # after would you add some host? add
    # while 
        # create group > hosts
        # 
}

Del_host(){}

Del_Group(){}


# Check if Ansible is here


# Take Info
read -p " Each Part would you want ? " respond01

# Group

# Host

# ssh-key