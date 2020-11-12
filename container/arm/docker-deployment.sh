#!/bin/sh

if [ -z "$EnvironmentResourceGroup" ]; then

    az deployment sub create --location "$EnvironmentLocation" \
                             --name "$DeploymentId" \
                             --no-prompt true --verbose \
                             --template-uri "$EnvironmentTemplateUrl" 

else

    az deployment group create  --location "$EnvironmentLocation" \
                                --resource-group "$EnvironmentResourceGroup"
                                --name "$DeploymentId" \
                                --no-prompt true --verbose \
                                --template-uri "$EnvironmentTemplateUrl" 

fi

tail -f /dev/null

