#!/bin/bash

# you will need global variables to access through out the script which are AMI ,SG

AMI=ami-0b4f379183e5706b9
SG_ID=sg-0637a74bfefa45c31

# you need to create multiple instances with different types
# mongodb, mysql, shipping we are creating t3.small remaining t2.micro
# creating route53 records, web public ip remaining private ip

#store instances in array

INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")

for i in "${INSTANCES[@]}"
do
echo -e "current instance is $i"
  if [ $i == "mongodb" ] || [ $i == "shipping" ] || [ $i == "mysql" ] ; then
    INSTANCE_TYPE="t3.small"
  else
    INSTANCE_TYPE="t3.micro"
  fi
    echo -e "$i setting instance type $INSTANCE_TYPE"
done

