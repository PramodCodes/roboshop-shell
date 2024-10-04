#!/bin/bash
set -x

# echo "File Name: $0"
# echo "First Parameter : $1"
# echo "Second Parameter : $2"
# echo "Quoted Values: $@"
# echo "Quoted Values: $*"
# echo "Total Number of Parameters : $#"

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

# check root user

ISROOT() {
    echo "checking if current user is root user"
    if [ $ID -eq 0 ]; then
        echo -e "$G[SUCCESS] Current user is root user$N"
    else
        echo -e "$R[FAIL] Current user is not root user$N"
    fi
}
# The following function checks validations
VALIDATE_INSTALL() {
    if [ $1 -eq 0 ]; then
        echo -e " $2 is success "
    else
        echo -e " $2 is failed "
        exit 1
    fi
}

ISROOT

# install nginx

dnf install nginx -y

VALIDATE_INSTALL $0 "nginix installation"
