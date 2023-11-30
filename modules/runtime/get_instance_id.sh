aws ec2 describe-instances --region us-east-2 |grep InstanceId

aws ec2 describe-instances --region us-east-2 | jq ".Reservations[].Instances[].PrivateDnsName"
"ip-10-0-1-153.us-east-2.compute.internal"
"ip-10-0-0-203.us-east-2.compute.internal"
