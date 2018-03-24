#!/bin/bash
###  Define Variables ###
seq=$RANDOM
base=uneidel
location=westeurope
RG=mioty$seq                                        #ResourceGroup
DEPLOYMENTNAME=$base$seq                            #DeploymentName inside Subscription
IoTHub_name=$base"hub"$seq                             #IoT HubName
DeviceId=SomeFancyIdName                            # Concentrator
gitrepo=https://github.com/uneidel/iotminidash      #Public Github Repository for WebSite
LogicApp_name=$base"logicapp"$seq
ServiceBus_name=$base"servicebus"$seq
StorageAccount_name=$base"storage"$seq
SBQueue_name=$base"sbqueue"$seq
WebApp_name=$base"webapp"$seq
WebAppCName=$base"app"$seq
### end Define ###

echo "Login into Azure - This can be done on any computer"
#az login  # Disabled due to debug Version

echo "adding sources"
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |  tee /etc/apt/sources.list.d/azure-cli.list
apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893 > /dev/null 2>&1
apt-get install apt-transport-https > /dev/null 2>&1
apt-get update &&  apt-get install -y azure-cli jq  > /dev/null 2>&1  #installing cli and jq for parsing json

## load extension
echo "Loading IoTExtension"
az extension add --name azure-cli-iot-ext > /dev/null 2>&1

echo "Create resourcegroup"
az group create --name $RG --location $location > /dev/null 2>&1

echo "Start Deployment"
az group deployment create --name $DEPLOYMENTNAME --resource-group $RG --template-file ./armtemplate.json --parameters "{\"IoTHub_name\": {\"value\": \"$IoTHub_name\"},\"LogicApp_name\": {\"value\": \"$LogicApp_name\"},\"ServiceBus_name\": {\"value\": \"$ServiceBus_name\"},\"StorageAccount_name\": {\"value\": \"$StorageAccount_name\"},\"SBQueue_name\": {\"value\": \"$SBQueue_name\"},\"WebApp_name\": {\"value\": \"$WebApp_name\"},\"WebAppCName\": {\"value\": \"$WebAppCName\"}}" > /dev/null 2>&1
echo "Starting WebappDeployment"
az webapp deployment source config --name $WebApp_name --resource-group $RG --repo-url $gitrepo --branch master --manual-integration > /dev/null 2>&1

#Create DeviceId 
echo "creating DeviceId and Setting EnvironmentVariable"
az iot hub device-identity create --hub-name $IoTHub_name --device-id $DeviceId > /dev/null 2>&1
CONNSTRING=$(az iot hub device-identity show-connection-string --device-id $DeviceId --hub-name $IoTHub_name)
CONN=$(echo $CONNSTRING | jq -r '.cs')
echo "ConnString for EnvironmentVariable: $CONN"
