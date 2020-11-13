#!/bin/bash

DeploymentName="$(uuidgen)"

track() { 
    
    echo "$1"; 
}

if [ -z "$EnvironmentResourceGroup" ]; then

    az deployment sub create    --location "$EnvironmentLocation" \
                                --name "$DeploymentName" \
                                --no-prompt true --no-wait \
                                --template-uri "$EnvironmentTemplateUrl" 

else

    az deployment group create  --resource-group "$EnvironmentResourceGroup" \
                                --name "$DeploymentName" \
                                --no-prompt true --no-wait \
                                --template-uri "$EnvironmentTemplateUrl" 

    while true; do

        sleep 5

        ProvisioningState=$(az deployment group show --resource-group "$EnvironmentResourceGroup" --name "$DeploymentName" --query "properties.provisioningState" -o tsv)

        track $(az deployment operation group list --resource-group "$EnvironmentResourceGroup" --name "$DeploymentName")
        
        if [[ "CANCELED|FAILED|SUCCEEDED" == *"${ProvisioningState^^}"* ]]; then

                echo "Deployment $DeploymentName: $ProvisioningState"
                break
        fi

    done
fi

tail -f /dev/null

