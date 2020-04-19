import json
import boto3

def lambda_handler(event, context):
    # region variable
    region = "eu-west-2"
    # list to hold network values
    mynetworks=[]
    # reacing my DynamoDB and my table
    mydynamo = boto3.resource("dynamodb")
    mytable = mydynamo.Table("network_table") 

    # ec2 resource    
    ec2 = boto3.resource('ec2', region_name=region)
    # ec2 client
    ec2client = boto3.client('ec2')
    # get related vpcs
    response = ec2client.describe_vpcs()
    # get related subnets
    response2 = ec2client.describe_subnets()
    # reach each vpc and related subnets and add them to mynetworks variable
    for vpc in response["Vpcs"]:
        mysubnets = []
        for subnet in response2["Subnets"]:
            if subnet["VpcId"] == vpc["VpcId"]:
                mysubnets.append(subnet["CidrBlock"])
        mynetworks.append({"VPCID" : vpc["VpcId"], "CIDR" : vpc["CidrBlock"], "SUBNET" : mysubnets})
    
 
    
    # putting values into DynamoDB
    for vpc in mynetworks:
        response = mytable.put_item(
        
            Item={
                "id":vpc["VPCID"],
                "cidr":vpc["CIDR"],
                "subnet":vpc["SUBNET"]
            }
        )
        
    # reading all values from DynamoDB
    response2 = mytable.scan()
    


    return {
        'statusCode': 200,
        'body': response2
    }
