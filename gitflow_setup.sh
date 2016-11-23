#!/bin/bash 

#declaring variables
export hooksdir="$HOME/.git/hooks"

#add setup options here
case "$1" in
        --debug)
                set -x
        ;;
        --hooksdir)
                hooksdir=$2
        ;;
esac

##################function definitions
install_gitflow () 
{
        status=$(dpkg -l git-flow)
        gitflow_installed=$?
        if [ $gitflow_installed -ne 0 ]; then
                sudo apt-get update
                sudo apt-get install git-flow
                gitflow_installed=$?
        else
                echo "git-flow package is intalled, proceed to the next step" 
                gitflow_installed=0
        fi
        if [ $gitflow_installed -ne 0 ]; then 
                echo "The installation of git-flow package was unsuccessfull"
                return 1
        fi
        return 0
}

download_hooks () 
{
        if [ -d "$hooksdir" ]; then
                if whiptail --yesno "the hooks directory exits ($hooksdir) - the do you wish to overwrite the contents?" 20 60 ;then
                        rm -rf $hooksdir
                        echo "cloning hooks repository into the specified location ($hooksdir)"
                        git clone https://github.com/petervanderdoes/git-flow-hooks.git $hooksdir
                        return $?
                else
                        echo "skipping..."    
                fi
        else
                echo "cloning hooks repository into the specified location ($hooksdir)"
                git clone https://github.com/petervanderdoes/git-flow-hooks.git $hooksdir
                return $?
        fi
}

setup_custom_hooks () 
{
        if whiptail --yesno "Copying custom hooks into the specified hooks location ($hooksdir) - do you wish to overwrite the contents?" 20 60 ;then
                cp "$PWD/custom_hooks/"* "$hooksdir/"
                return $?
        else
                echo "skipping..."
                return 0
        fi
}

#########################################
                
#1. installing git-flow
install_gitflow
if [ $? -ne 0 ]; then
    echo "There was a problem with git-flow installation, exiting"
    exit 1
fi

#2. downloading fresh set of hooks
download_hooks
if [ $? -ne 0 ]; then
    echo "There was a problem with downloading git-hooks"
    exit 1
fi

#3. setting up custom hooks
setup_custom_hooks
if [ $? -ne 0 ]; then
    echo "There was a problem with setting up custom git-flow hooks"
    exit 1
fi

echo "The setup finished successfully"
exit 0
