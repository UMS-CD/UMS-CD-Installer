#!/usr/bin/bash

function read-conf() {
    if [ -e /etc/ums-cd/install.conf ]; then
        while read var value
        do
            export "$var"="$value"
        done < /etc/ums-cd/install.conf
    fi
}

function install-wireguard-client() {
    apt-get install -y wireguard resolvconf

    sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf;
    /sbin/sysctl -w net.ipv4.ip_forward=1;

    echo -e "${WireguardConfClientPvKey[$serverNum -2]}" > /etc/wireguard/privatekey;
    echo -e "${WireguardConfClientPbKey[$serverNum -2]}" > /etc/wireguard/publickey;

    echo -e "${WireguardConfClient[$serverNum -2]}" > /etc/wireguard/wg0.conf;

    chmod 600 -R /etc/wireguard/;
}


function install-wireguard-server() {
    apt-get install wireguard resolvconf -y

    echo -e "${wireguardPvKeyServer}" > /etc/wireguard/privatekey;
    echo -e "${wireguardPbKeyServer}" > /etc/wireguard/publickey;

    echo -e "${wireguardConfServer}" > /etc/wireguard/wg0.conf;
    chmod 600 -R /etc/wireguard/;
}


function install-wireguard() {
    if [ $backendOrFrontend == "backend" 2>/dev/null ]; then
        install-wireguard-client
    else
        install-wireguard-server
    fi
}

read-conf
$1