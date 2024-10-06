#!/bin/bash

set -x # command tracing
set -e #  exit on error
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

ID=$(id -u) &>> "$LOGFILE"

ROOTCHECK(){
  echo
  if [ "$ID" -eq 0 ]; then
    echo -e "$G Root user $N"
  else
    echo  -e "$R Not root user $N"
    exit 1
  fi
  }
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$0-"$TIMESTAMP".log

VALIDATE(){

  if [ "$1" -eq 0 ]; then
        echo -e "$2" "$G is Successful $N"
  else
        echo -e "$2" "$R Failed $N"
  fi
  }

ROOTCHECK &>> "$LOGFILE"
VALIDATE $? "checking if root "



#Dispatch
#Dispatch is the service which dispatches the product after purchase. It is written in GoLang, So wanted to install GoLang.
#Install GoLang

dnf install golang -y &>> "$LOGFILE"
VALIDATE $? "install golang "

#Configure the application.

#Add application User

useradd roboshop &>> "$LOGFILE"
VALIDATE $? "add user roboshop "
#Lets setup an app directory.

mkdir /app &>> "$LOGFILE"
VALIDATE $? "created directory app "
#Download the application code to created app directory.

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>> "$LOGFILE"
VALIDATE $? "download dispatch "
cd /app &>> "$LOGFILE"
VALIDATE $? "created app directory "
unzip /tmp/dispatch.zip &>> "$LOGFILE"
VALIDATE $? "unzip dispatch "
#Every application is developed by development team will have some common softwares that they use as libraries. This application also have the same way of defined dependencies in the application configuration.
#Lets download the dependencies & build the software.

cd /app &>> "$LOGFILE"
VALIDATE $? "create app directory "
go mod init dispatch &>> "$LOGFILE"
VALIDATE $? "init dispatch "
go get &>> "$LOGFILE"
VALIDATE $? "go get app"
go build &>> "$LOGFILE"
VALIDATE $? "build go app"
#We need to setup a new service in systemd so systemctl can manage this service

#Setup SystemD Dispatch Service

{cp /root/roboshop-shell/configuration/dispatch.service /etc/systemd/system/dispatch.service; } &>> "$LOGFILE"
VALIDATE $? "creation of dispatch service"

#Load the service.

systemctl daemon-reload &>> "$LOGFILE"
VALIDATE $? "reload daemon "
#Start the service.

systemctl enable dispatch &>> "$LOGFILE"
VALIDATE $? "enable dispatch "
systemctl start dispatch &>> "$LOGFILE"
VALIDATE $? "start dispatch "