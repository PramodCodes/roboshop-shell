#!/bin/bash
set -x
#User
#User is a microservice that is responsible for User Logins and Registrations Service in RobotShop e-commerce portal.
#Developer has chosen NodeJs, Check with developer which version of NodeJS is needed. Developer has set a context that it can work with NodeJS >18
#Install NodeJS, By default NodeJS 10 is available, We would like to enable 18 version and install list.
#you can list modules by using dnf module list
# Setting colors for logging
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"


echo -e "Started logging at $TIMESTAMP" &>> "$LOGFILE"
# reading current user
ID=$(id -u)

ISROOT() {
 if [ "$ID" -eq 0 ] ; then
    echo  -e "$G user ISROOT $N" &>> "$LOGFILE"
  else
    echo  -e "$R user is not ROOT $N" &>> "$LOGFILE"
 fi
}
VALIDATE(){
    if [ "$1" -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N" &>> "$LOGFILE"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" &>> "$LOGFILE"
    fi
}
ISROOT
dnf module disable nodejs -y &>> "$LOGFILE"
VALIDATE $? "disable node nodejs"
dnf module enable nodejs:18 -y &>> "$LOGFILE"
VALIDATE $? "enable nodejs 18"
#Install NodeJS
dnf install nodejs -y &>> "$LOGFILE"
VALIDATE $?
#Configure the application.
#Add application User
#useradd roboshop &>> "$LOGFILE"
id roboshop #if roboshop user does not exist, then it is failure
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

#Lets setup an app directory.
mkdir -p /app &>> "$LOGFILE"
VALIDATE $? "app directory creation"

#Download the application code to created app directory.

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>> "$LOGFILE"
VALIDATE $? "download the user zip"

cd /app &>> "$LOGFILE"
VALIDATE $? "create app dir"

unzip -o /tmp/user.zip &>> "$LOGFILE" # this command will replace files if already partially unzipped
VALIDATE $? "extract the zip"

#Every application is developed by development team will have some common softwares that they use as libraries. This application also have the same way of defined dependencies in the application configuration.

#Lets download the dependencies.

npm install &>> "$LOGFILE"
VALIDATE $? "Installing dependencies"

#We need to setup a new service in systemd so systemctl can manage this service

#Setup SystemD User Service
#vim /etc/systemd/system/user.service
pwd &>> "$LOGFILE"

cd ~/roboshop-shell &>> "$LOGFILE"
VALIDATE $? "navigating into roboshop"

{ cp configuration/user.service /etc/systemd/system/user.service; } &>> "$LOGFILE"
#{ cp /home/centos/roboshop-shell/configuration/user.service /etc/systemd/system/user.service; } &>> "$LOGFILE"

VALIDATE $? "Copying user service file"

#     configuration/user.service
#Load the service.

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "Enable user"

systemctl start user &>> $LOGFILE
VALIDATE $? "Starting user"


#For the application to work fully functional we need to load schema to the Database. Then
#NOTE: Schemas are usually part of application code and developer will provide them as part of development.
#We need to load the schema. To load schema we need to install mongodb client.
#To have it installed we can setup MongoDB repo and install mongodb-client

#vim /etc/yum.repos.d/mongo.repo &>> "$LOGFILE"
cd ~/roboshop-shell &>> "$LOGFILE"

{ cp /configuration/mongo.repo /etc/yum.repos.d/mongo.repo; } &>> "$LOGFILE"
VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y  &>> "$LOGFILE"
VALIDATE $? "Installing MongoDB client"

#Load Schema

mongo --host mongodb.pka.in.net </app/schema/user.js &>> "$LOGFILE"
VALIDATE $? "Loading user data into MongoDB"

echo -e "$Y User Application installed successfully $N"
