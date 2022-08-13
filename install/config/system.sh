#!/usr/bin/bash

def read() {
    if [ -e /etc/ums-cd/install.conf ]; then
        while read var value
        do
            export "$var"="$value"
        done < /etc/ums-cd/install.conf
    fi
}

function addAdministrator() {
    apt-get install -y sudo

    UTILISATEUR=$userName
    PASSWORD=$userPass

    DESCRIPTION=Administrateur
    USER_ID=1100
    GROUP=users

    /usr/sbin/useradd             \
    --home-dir /home/$UTILISATEUR \
    --base-dir /home/$UTILISATEUR \
    --uid $USER_ID                \
    --groups $GROUP               \
    --no-user-group               \
    --shell /bin/bash             \
    --comment "$DESCRIPTION"      \
    --create-home $UTILISATEUR 2>/dev/null

    echo $UTILISATEUR:$PASSWORD | chpasswd;

    echo "$UTILISATEUR ALL=(ALL) PASSWD: ALL" > /etc/sudoers.d/$UTILISATEUR
}


function rootPassword() {
    echo root:$rootPass | chpasswd;
}


function changeHostname() {
    hostname="${backendOrFrontend}-${serverNum}-${lowerInfraName}"
    echo $hostname > /etc/hostname
}