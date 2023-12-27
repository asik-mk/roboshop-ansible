#!/bin/bash
ID=$(id -u)
INSTANCES=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "dispatch" "web")
DN="mohammedasik.shop"

if ( $ID -ne 0 )
then
    echo " Switch to root user "
    exit 1;
else
    echo " SIT TIGHT "
fi

for i in "${INSTANCES[@]}"
do

    IPADDRESS=$(aws ec2 run-instances \
        --image-id ami-03265a0778a880afb \
        --instance-type t2.micro \
        --count 1 \
        --security-group-ids sg-0a7b5d6d0aaba9852 \
        --tag-specifications "ResourceType=instance,Tags=[{Key=webserver,Value=$INSTANCES}]" \
        --query 'Instances[0].PrivateIpAddress' --output text)

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
    '
done
