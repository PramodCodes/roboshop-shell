#!/bin/bash

# get current user id
ID=$(id -u)

#color codes for formatting logs
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# enabling debugging
set -x

#check for root

ISROOT() {
    echo "checking if current user is root user"
    if [ $ID -eq 0 ]; then
        echo -e "$G current user is a root user $N"
    else
        echo -e "$R current user is not root $N"
        exit 1
    fi
}

ISROOT
