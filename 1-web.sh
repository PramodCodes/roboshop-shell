#!/bin/bash
set -x

# echo "File Name: $0"
# echo "First Parameter : $1"
# echo "Second Parameter : $2"
# echo "Quoted Values: $@"
# echo "Quoted Values: $*"
# echo "Total Number of Parameters : $#"
# echo "Exit status of last command : $?"

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
VALIDATE() {
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

VALIDATE $? "nginx installation"

# Start & Enable Nginx service

systemctl enable nginx
systemctl start nginx

VALIDATE $? "nginx starting"

# Remove the default content that web server is serving.

rm -rf /usr/share/nginx/html/*

VALIDATE $? "default content removal"

# Download the frontend content

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "frontend content download"

# Extract the frontend content.
cd /usr/share/nginx/html
VALIDATE $? "navigation to html Content"

unzip /tmp/web.zip
VALIDATE $? "extraction of frontend Content"

# Create Nginx Reverse Proxy Configuration.
echo "Creating reverse proxy configuration
echo " $G current path is " pwd $N
