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



#RabbitMQ
#RabbitMQ is a messaging Queue which is used by some components of the applications.
#Configure YUM Repos from the script provided by vendor.

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> "$LOGFILE"
VALIDATE $? "Downloading rabbitmq script "
#Configure YUM Repos for RabbitMQ.

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> "$LOGFILE"
VALIDATE $? "downloading rabbitmq server package "

#Install RabbitMQ

dnf install rabbitmq-server -y &>> "$LOGFILE"
VALIDATE $? "installing rabbitmq server "
#Start RabbitMQ Service

systemctl enable rabbitmq-server &>> "$LOGFILE"
VALIDATE $? "enabling rabbitmq server "
systemctl start rabbitmq-server &>> "$LOGFILE"
VALIDATE $? "starting rabbitmq server"
#RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect. Hence, we need to create one user for the application.

rabbitmqctl add_user roboshop roboshop123 &>> "$LOGFILE"
VALIDATE $? "adding roboshop user  "
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> "$LOGFILE"
VALIDATE $? "Setting set_permissions for roboshop  "