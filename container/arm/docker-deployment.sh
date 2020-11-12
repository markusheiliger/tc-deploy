#!/bin/sh

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

        $ProvisioningState=$(az deployment group show --resource-group "$EnvironmentResourceGroup" --name "$DeploymentName" --query "properties.provisioningState" -o tsv)

        case "${ProvisioningState^^}" in
            *)
                track $(az deployment operation group list --resource-group "$EnvironmentResourceGroup" --name "$DeploymentName")
                ;;&
            "CANCELED" | "FAILED" | "SUCCEEDED")
                echo "DEPLOYMENT ${ProvisioningState^^}"
                break
        esac

    done
fi





tail -f /dev/null

