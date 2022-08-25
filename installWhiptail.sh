#!/usr/bin/bash

function allInstallPart1() {
    bash ./install/service/system/command.sh installLVMCommand
    bash ./install/config/apt.sh aptSourceList
    bash ./install/config/system.sh rootPassword
    bash ./install/config/system.sh addAdministrator
    bash ./install/config/system.sh changeHostname
    bash ./install/service/system/timeshift.sh installTimeshift
    echo "cd /root/UMS-CD-Installer && bash install.sh Part2" > /root/.bashrc

    reboot
}


function allInstallPart2() {
    echo "" > /root/.bashrc
    bash ./install/config/ssh.sh sshConfig
    bash ./install/network/wireguard.sh installWireguard
    bash ./install/network/interface.sh networkSet
    bash ./install/service/system/proxmox.sh installProxmox
    echo "cd /root/UMS-CD-Installer && bash install.sh Part3" > /root/.bashrc

    reboot
}


function allInstallPart3() {
    echo "" > /root/.bashrc
    bash ./install/service/system/proxmox.sh postInstallProxmox
    bash ./install/service/system/docker.sh installDocker

    reboot
}

function mainMenu() {
    while true; do
        clear
        allAuestion
        clear

        if [ $USER == "root" ]; then
            choiceInstallMethod=$(whiptail --title "UMS-CD Installer" --menu "Choose an install method" 15 60 3 \
            "autoInstall" "Automatic Installation" \
            "manualInstall" "Manual Installation" \
            "editMenu" "Open Edit Menu" 3>&1 1>&2 2>&3)

            if [ $choiceInstallMethod == "autoInstall" ]; then
                allInstallPart1
            else if [ $choiceInstallMethod == "editMenu"] then
                editMenu
            fi

            if [ -z $choiceInstallMethod ]; then
                break
            fi

            if [ $choiceInstallMethod == "manualInstall" ]; then
                choiceInstallRoot=$(whiptail --title "UMS-CD Manual Installer" --menu "Choose an option" 15 60 14 \
                "timeshift" "Install and Configure Timeshift" \
                "rootPassword" "Set Root Password" \
                "user" "Add An Administrator" \
                "sshConfigure" "Configure SSH" \
                "listApt" "Add APT Sources List" \
                "vlanServer" "Configure Network Interface" \
                "hostname" "Configure Hostname" \
                "wireguardClient" "Configure Wireguard Client" \
                "nameServer" "Start taking defined backup" \
                "proxmoxP1" "Install Proxmox (Part 1)" \
                "proxmoxP2" "Install Proxmox (Part 2)" \
                "docker" "Install Docker" 3>&1 1>&2 2>&3)

                if [ -z $choiceInstallRoot ]; then
                break
                fi

                case $choiceInstallRoot in
                    Hostname ) bash ./install/config/system.sh changeHostname;;
                    VlanServer ) bash ./install/network/interface.sh networkSet;;
                    ListApt ) bash ./install/config/apt.sh aptSourceList;;
                    RootPassword ) bash ./install/config/system.sh rootPassword;;
                    User ) bash ./install/config/system.sh addAdministrator;;
                    WireguardClient ) bash ./install/network/wireguard.sh installWireguardClient;;
                    NameServer ) bash ./install/service/system/timeshift.sh installTimeshift;;
                    ProxmoxP1 ) bash ./install/service/system/proxmox.sh installProxmox;;
                    ProxmoxP2 ) bash ./install/service/system/proxmox.sh postInstallProxmox;;
                    Docker ) bash ./install/service/system/docker.sh installDocker;;
                    SshConfigure ) bash ./install/config/ssh.sh sshConfig;;
                    NameServer ) bash ./install/network/interface.sh fixNameServer;;
                esac
            fi    
        fi
    done
}


function editMenu() {
    while true; do
        clear
            choice=$(whiptail --title "UMS Tweaker" --menu "Choose an Option" 15 60 3 \
            "lvm" "LVM Resize" \
            "changeDns" "Change DNS Settings" \
            "shareSshKey" "Share SSH Key to Other Servers" \
            "clearLogs" "Clear Server Logs" \
            "fixNetwork" "Reload and Reconfigure Network Settings" 3>&1 1>&2 2>&3)
        if [ -z $choice ]; then
            break
        fi
        case $choice in
            lvm ) lvmMenu;;
            changeDns ) changeDns;;
            shareSshKey ) shareSshKey;;
            clearLogs ) clearLogs;;
            fixNetwork ) fixNetwork;;
        esac
    done
}
function lvmMenu() {
    while true; do
        clear
            choice=$(whiptail --title "UMS Tweaker : LVM" --menu "Choose an Option" 15 60 3 \
            "extend" "extend LVM partition" \
            "retract" "retract LVM partition" 3>&1 1>&2 2>&3)

        case $choice in
            extend ) lvm-extend;;
            retract ) lvm-retract;;
        esac
    done
}

    if [ -z $1 ]; then
        mainMenu
        else if [$1 == "Part2"] then
            allInstallPart2
            else if [$1 == "Part3"] then
                allInstallPart3
            fi
        fi
    fi
