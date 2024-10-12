#!/bin/bash
set -x # command tracing
set -e #  exit on error
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE=/tmp/$0-"$TIMESTAMP".log
ID=$(id -u) &>>"$LOGFILE"

ROOTCHECK() {
  echo
  if [ "$ID" -eq 0 ]; then
    echo -e "$G Root user $N"
  else
    echo -e "$R Not root user $N"
    exit 1
  fi
}

VALIDATE() {

  if [ "$1" -eq 0 ]; then
    echo -e "$2" "$G is Successful $N"
  else
    echo -e "$2" "$R Failed $N"
  fi
}

ROOTCHECK &>>"$LOGFILE"
VALIDATE $? "checking if root "
#Shipping
#Shipping service is responsible for finding the distance of the package to be shipped and calculate the price based on that.
#Shipping service is written in Java, Hence we need to install Java.
#Maven is a Java Packaging software, Hence we are going to install maven, This indeed takes care of java installation.

dnf install maven -y &>>"$LOGFILE"
VALIDATE $? "Maven installation "

#Configure the application.
#Add application User

useradd roboshop &>>"$LOGFILE"
VALIDATE $? " adding user roboshop "

#Lets setup an app directory.

mkdir -p /app &>>"$LOGFILE" # -p create if not exist
VALIDATE $? " creation of app directory"
#Download the application code to created app directory.

curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>"$LOGFILE"
VALIDATE $? "Downloading shipping catalogue file"

cd /app &>>"$LOGFILE"
VALIDATE $? "Navigation to app directory "

unzip /tmp/shipping.zip &>>"$LOGFILE"
VALIDATE $? "Inflating shipping archive"
#Every application is developed by development team will have some common software that they use as libraries. This application also have the same way of defined dependencies in the application configuration.
#Lets download the dependencies & build the application

cd /app &>>"$LOGFILE"
VALIDATE $? "Navigating to app directory "

mvn clean package &>>"$LOGFILE"
VALIDATE $? "Running maven clean package to build the app "

mv target/shipping-1.0.jar shipping.jar &>>"$LOGFILE"
VALIDATE $? "Moving jar file to target directory "

#We need to setup a new service in systemd so systemctl can manage this service
#Setup SystemD Shipping Service

#/etc/systemd/system/shipping.service
{ cp /root/roboshop-shell/configuration/shipping.service /etc/systemd/system/shipping.service; } &>>"$LOGFILE"
VALIDATE $? "Creating shipping service configuration by moving the file from configuration directory "

#Load the service.

systemctl daemon-reload &>>"$LOGFILE"
VALIDATE $? "Reloading the service daemon "
#Start the service.

systemctl enable shipping &>>"$LOGFILE"
VALIDATE $? "Enabling shipping service "
systemctl start shipping &>>"$LOGFILE"
VALIDATE $? "Starting shipping service "
#For this application to work fully functional we need to load schema to the Database.
#We need to load the schema. To load schema we need to install mysql client.
#To have it installed we can use

dnf install mysql -y &>>"$LOGFILE"
VALIDATE $? "Install mysql client "
#Load Schema

mysql -h mysql.pka.in.net -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>"$LOGFILE"
VALIDATE $? "Connecting with mysql server "
#This service needs a restart because it is dependent on schema, After loading schema only it will work as expected, Hence we are restarting this service. This

systemctl restart shipping &>>"$LOGFILE"
VALIDATE $? "Restarting shipping service"

echo -e "$Y shipping service configuration is complete check the connection status in netstat -lntp $N"
