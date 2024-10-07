#!/bin/bash
# Redis is offering the repo file as a rpm. Lets install it
set -xe
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
    echo  -e "$G user ISROOT $N"
  else
    echo  -e "$R user is not ROOT $N"
 fi
}
VALIDATE(){
    if [ "$1" -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}
ISROOT
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> "$LOGFILE"
VALIDATE $? "installation of remi"
#Enable Redis 6.2 from package streams.

dnf module enable redis:remi-6.2 -y &>> "$LOGFILE"
VALIDATE $? "enabling redis"

#Install Redis
dnf install redis -y &>> "$LOGFILE"
VALIDATE $? "Installing redis"
#Usually Redis opens the port only to localhost(127.0.0.1), meaning this service can be accessed by the application that is hosted on this server only. However, we need to access this service to be accessed by another server, So we need to change the config accordingly.
#Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/redis.conf & /etc/redis/redis.conf

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf &>> "$LOGFILE"
VALIDATE $? "pointing the /etc/redis.conf  to internet"
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>> "$LOGFILE"
VALIDATE $? "pointing the /etc/redis/redis.conf  to internet"
#vim /etc/redis.conf
#Start & Enable Redis Service

systemctl enable redis &>> "$LOGFILE"
VALIDATE $? "enabling redis"
systemctl start redis &>> "$LOGFILE"
VALIDATE $? "Started redis"

echo -e "$Y configuration of redis is success $N"