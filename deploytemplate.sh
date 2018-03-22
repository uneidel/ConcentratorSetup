#!/bin/bash
seq=$RANDOM
echo $RANDOM 
RG=mioty$seq
DEPLOYMENTNAME=mioty$seq
az group create --name $RG --location "westeurope" 
 
az group deployment create --name $DEPLOYMENTNAME --resource-group $RG --template-file .\armtemplate.json #\ 
# --parameters "{\"newStorageAccountName\": {\"value\": \"jasondisks321\"},\"adminUsername\": {\"value\": \"jason\"},\"adminPassword\": {\"value\": \"122130869@qq\"},\"dnsNameForPublicIP\": {\"value\": \"jasontest321\"}}" 