import os
from ipaddress import ip_network, ip_address
import uuid
import ast
from os import getenv



def check_environment_variables(environment_variables):
    for env in environment_variables:
        if getenv(env) == None:
            print('IP addres', env, 'is not set. Exiting')
            exit(1)


check_environment_variables([
    'IP_RANGE'
])

def check_ip(IP_ADDRESS, IP_RANGES):
    VALID_IP = False
    for IP_RANGE in IP_RANGES:
        cidr_blocks = list(filter(lambda element: "/" in element, IP_RANGE))
        if cidr_blocks:
            for cidr in cidr_blocks:
                net = ip_network(cidr)
                VALID_IP = ip_address(IP_ADDRESS) in net
                if VALID_IP:
                    break
        if not VALID_IP and IP_ADDRESS in IP_RANGE:
            VALID_IP = True

        if VALID_IP:
            break

    return VALID_IP


def lambda_handler(event, context):
    
    IP_ADDRESS = event['requestContext']['identity']['sourceIp']
    IP_RANGE = getenv('IP_RANGE').split(',')
    VALID_IP = check_ip(IP_ADDRESS, IP_RANGE)
    API_ID = event["requestContext"]["apiId"]
    ACC_ID = event["requestContext"]["accountId"]
    METHOD = event["requestContext"]["httpMethod"]
    STAGE = "$default"
    ROUTE = event["requestContext"]["resourcePath"]

    if VALID_IP:

        response = {
            "principalId": f"{uuid.uuid4().hex}",
            "policyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Action": "execute-api:Invoke",
                        "Effect": "Allow",
                        "Resource": f"arn:aws:execute-api:us-east-1:{ACC_ID}:{API_ID}/{STAGE}/{METHOD}{ROUTE}",
                    }
                ],
            },
            "context": {"exampleKey": "exampleValue"},
        }

        return response

    response = {
        "principalId": f"{uuid.uuid4().hex}",
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": "Deny",
                    "Resource": f"arn:aws:execute-api:us-east-1:{ACC_ID}:{API_ID}/*/*/*",
                }
            ],
        },
        "context": {"exampleKey": "exampleValue"},
    }

    return response