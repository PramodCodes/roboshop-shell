#!/bin/bash
set -xe
# you will need global variables to access through out the script which are AMI ,SG

AMI=ami-0b4f379183e5706b9
SG_ID=sg-0637a74bfefa45c31
ENV=test
ZONE_ID=Z056232231439EYIBQD0B
DOMAIN_NAME=pka.in.net
PRIVATE_IP=0.0.0.0
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
    echo -e "$i - $INSTANCE_TYPE"

#  aws ec2 run-instances --image-id $AMI --count 1 --instance-type $INSTANCE_TYPE --key-name nv --security-group-ids $SG_ID --subnet-id subnet-08552b8a3fc9570b4
#the above command wont add the name to the server so lets modify it


#aws ec2 run-instances --image-id $AMI --count 1 --instance-type $INSTANCE_TYPE --key-name nv --security-group-ids $SG_ID --subnet-id subnet-08552b8a3fc9570b4 --tag-specifications "ResourceType=instance,Tags=[{Key=env,Value=test},{Key=Name,Value=$i}]"
#you need to get ip address of created instance to create a record in route 53 we use query for it
#aws ec2 run-instances --image-id $AMI --count 1 --instance-type $INSTANCE_TYPE --key-name nv --security-group-ids $SG_ID --subnet-id subnet-08552b8a3fc9570b4 \
#--tag-specifications "ResourceType=instance,Tags=[{Key=env,Value=$ENV},{Key=Name,Value=$i}]" --query 'Instances[*].PrivateIpAddress' --output text
#save the ip address in variable
PRIVATE_IP=$(aws ec2 run-instances --image-id $AMI --count 1 --instance-type $INSTANCE_TYPE --key-name nv --security-group-ids $SG_ID --subnet-id subnet-08552b8a3fc9570b4 --tag-specifications "ResourceType=instance,Tags=[{Key=env,Value=$ENV},{Key=Name,Value=$i}]" --query 'Instances[*].PrivateIpAddress' --output text)
  echo -e "$i - $INSTANCE_TYPE - $PRIVATE_IP"

# once the instance is created we need to get private ip address of created instance to create a route53 record
#CREATE r53 and make sure delete existing records


# Creates route 53 records based on env name

aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch "
  {
    "Comment": "creating a record set for {$i}"
    ,"Changes": [{
      "Action"              : "CREATE"
      ,"ResourceRecordSet"  : {
          "Name"              : "{$i}.{$DOMAIN_NAME}"
          ,"Type"             : "A"
          ,"TTL"              : 1
          ,"ResourceRecords"  : [{
              "Value"         : "{$PRIVATE_IP}"
        }]
      }
    }]
  }
  "

done
