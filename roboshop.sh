#!/bin/bash
ID=$(id -u)
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
DN="mohammedasik.shop"
AMI="ami-03265a0778a880afb"
SG="sg-0a7b5d6d0aaba9852"

if [ $ID -ne 0 ]
then
    echo " Switch to root user "
    exit 1;
else
    echo " SIT TIGHT "
fi

for i in "${INSTANCES[@]}"
do
    echo "Instance is : $i"
    if [ $i == "mongodb" ] || [ $i == "mysql" ] || [ $i == "shipping" ]
    then
        INSTANCE_TYPE="t2.micro"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    IP_ADDRESS=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SG --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" --query 'Instances[0].PrivateIpAddress' --output text)

    aws route53 change-resource-record-sets \
    --hosted-zone-id Z05281403KGB5KOKKHZHT \
    --change-batch '
    {
        "Comment": "Creating a record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$i'.'$DN'"
            ,"Type"             : "A"
            ,"TTL"              : 0
            ,"ResourceRecords"  : [{
                "Value"         : "'$IPADDRESS'"
            }]
        }
        }]
    }
    ' &>> /tmp/logfile.txt
done
