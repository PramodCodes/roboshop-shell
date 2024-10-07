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


#Payment
#This service is responsible for payments in RoboShop e-commerce app. This service is written on Python 3.6, So need it to run this app.
#Install Python 3.6

dnf install python36 gcc python3-devel -y &>> "$LOGFILE"
VALIDATE $? "install python gcc python3 "
#Configure the application.
#Add application User

useradd roboshop &>> "$LOGFILE"
VALIDATE $? "create roboshop user "
#Lets setup an app directory.

mkdir /app &>> "$LOGFILE"
VALIDATE $? "create directory app "
#Download the application code to created app directory.

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>> "$LOGFILE"
VALIDATE $? "download the payment archive "
cd /app &>> "$LOGFILE"
VALIDATE $? "navigate to app directory "
unzip /tmp/payment.zip &>> "$LOGFILE"
VALIDATE $? "inflate payment archive "
#Every application is developed by development team will have some common softwares that they use as libraries. This application also have the same way of defined dependencies in the application configuration.
#Lets download the dependencies.

cd /app &>> "$LOGFILE"
VALIDATE $? "navigate to directory app "
pip3.6 install -r requirements.txt &>> "$LOGFILE"
VALIDATE $? "install python requirements "
#We need to setup a new service in systemd so systemctl can manage this service
#Setup SystemD Payment Service

{ cp /root/roboshop-shell/configuration/payment.service /etc/systemd/system/payment.service; } &>> "$LOGFILE"
VALIDATE $? "copy payment service "
#Load the service.

systemctl daemon-reload &>> "$LOGFILE"
VALIDATE $? "reload daemon "
#Start the service.

systemctl enable payment &>> "$LOGFILE"
VALIDATE $? "enable the payment "
systemctl start payment &>> "$LOGFILE"
VALIDATE $? "start the payment app "
echo -e "$Y payment Application installed successfully $N"
