#!/bin/bash

# get current user id
ID=$(id -u)

#color codes for formatting logs
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# enabling debugging
set -x # command tracing
set -e #  exit on error
#check for root
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$0-"$TIMESTAMP".log

ISROOT() {
    echo "checking if current user is root user"
    if [ $ID -eq 0 ]; then
        echo -e "$G current user is a root user $N"
    else
        echo -e "$R current user is not root $N"
        exit 1
    fi
}

VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "$G $2 is success$N"
    else
        echo -e "$R $2 is failed $N"
        exit 1
    fi
}

ISROOT

# Install NodeJS, By default NodeJS 10 is available, We would like to enable 18 version and install list.
# you can list modules by using dnf module list
dnf module disable nodejs -y &>>"$LOGFILE"
VALIDATE $? "Disabling current NodeJS"

dnf module enable nodejs:18 -y &>>"$LOGFILE"
VALIDATE $? "Enabling NodeJS:18"

# Install NodeJS &>> "$LOGFILE"
# VALIDATE $? "Installing NodeJS:18"

dnf install nodejs -y &>>"$LOGFILE"
VALIDATE $? "Installing NodeJS"

# Configure the application.
# Add application User

id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]; then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

# Lets setup an app directory.
mkdir -p /app &>>"$LOGFILE"
VALIDATE $? "app directory creation"

# Download the application code to created app directory.
curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>"$LOGFILE"
VALIDATE $? "Downloading cart application"

cd /app &>>"$LOGFILE"
VALIDATE $? "Naviagting into app directory"

unzip -o /tmp/cart.zip &>>"$LOGFILE"
VALIDATE $? "unzipping cart"

# Every application is developed by development team will have some common softwares that they use as libraries. This application also have the same way of defined dependencies in the application configuration.
# Lets download the dependencies.

cd /app &>>"$LOGFILE"
VALIDATE $? "Naviagting into app directory"

npm install &>>"$LOGFILE"
VALIDATE $? "Installing dependencies"

# We need to setup a new service in systemd so systemctl can manage this service
# Setup SystemD Cart Service
# since below command wont work with automation i will copy file from configuration dir
# vim /etc/systemd/system/cart.service

# Load the service.
cp /root/roboshop-shell/configuration/cart.service /etc/systemd/system/cart.service &>>"$LOGFILE"
VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>>"$LOGFILE"
VALIDATE $? "cart daemon reload"

systemctl enable cart &>>"$LOGFILE"
VALIDATE $? "Enable cart"

systemctl start cart &>>"$LOGFILE"
VALIDATE $? "Starting cart"

echo -e "$Y Cart Application installed successfully $N"
