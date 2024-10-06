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

#MySQL
#Developer has chosen the database MySQL. Hence, we are trying to install it up and configure it.
#CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version.
dnf module disable mysql -y &>> "$LOGFILE"
VALIDATE $? "Disable mysql"
#Setup the MySQL5.7 repo file
{ cp /root/roboshop-shell/configuration/myql.repo /etc/yum.repos.d/mysql.repo; } &>> "$LOGFILE"
VALIDATE $? "mysql repo setup"


#Install MySQL Server
dnf install mysql-community-server -y &>> "$LOGFILE"
VALIDATE $? "mysql installation"

#Start MySQL Service
systemctl enable mysqld &>> "$LOGFILE"
VALIDATE $? "enable mysql"

systemctl start mysqld &>> "$LOGFILE"
VALIDATE $? "mysql starting"


#Next, We need to change the default root password in order to start using the database service. Use password RoboShop@1 or any other as per your choice.

mysql_secure_installation --set-root-pass RoboShop@1 &>> "$LOGFILE"
VALIDATE $? "mysql root password setup"

#You can check the new password working or not using the following command in MySQL.

mysql -uroot -pRoboShop@1 &>> "$LOGFILE"
VALIDATE $? "mysql login"

echo -e "$Y SQL server is setup and operational $N"

