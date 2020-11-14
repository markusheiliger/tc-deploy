#!/bin/bash

trackDeployment() { 
    
    echo "$1"; 
}

EnvironmentTemplateUrlSecure="$(echo "$EnvironmentTemplateUrl" | sed 's/^http:/https:/g')"
EnvironmentDeploymentName="$(uuidgen)"
EnvironmentTemplateParametersJson=$(echo "$EnvironmentTemplateParameters" | jq --compact-output '{ "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#", "contentVersion": "1.0.0.0", "parameters": (to_entries | if length == 0 then {} else (map( { (.key): { "value": .value } } ) | add) end) }' )
EnvironmentTemplateParametersOpts=()

$(cat "$EnvironmentTemplateFile" | jq --raw-output '.parameters | to_entries[] | select( .key | startswith("_artifactsLocation")) | .key' ) | while read p; do
    case "$p" in
        _artifactsLocation)
            EnvironmentTemplateParametersOpts+=( --parameters _artifactsLocation="$(dirname EnvironmentTemplateUrlSecure)" )
            ;;
        _artifactsLocationSasToken)
            EnvironmentTemplateParametersOpts+=( --parameters _artifactsLocation="?code=EnvironmentTemplateUrlToken" )
            ;;
    esac
done

if [ -z "$EnvironmentResourceGroup" ]; then

    az deployment sub create    --location "$EnvironmentLocation" \
                                --name "$EnvironmentDeploymentName" \
                                --no-prompt true --no-wait \
                                --template-uri "$EnvironmentTemplateUrlSecure" \
                                --parameters "$EnvironmentTemplateParametersJson" \
                                "${EnvironmentTemplateParametersOpts[@]}"

    if [ $? -eq 0 ]; then # deployment successfully created

        while true; do

            sleep 5

            ProvisioningState=$(az deployment sub show --name "$EnvironmentDeploymentName" --query "properties.provisioningState" -o tsv)
            ProvisioningDetails=$(az deployment operation sub list --name "$EnvironmentDeploymentName")

            trackDeployment "$ProvisioningDetails"
            
            if [[ "CANCELED|FAILED|SUCCEEDED" == *"${ProvisioningState^^}"* ]]; then

                    echo "Deployment $EnvironmentDeploymentName: $ProvisioningState"
                    break
            fi

        done
    fi

else

    az deployment group create  --resource-group "$EnvironmentResourceGroup" \
                                --name "$EnvironmentDeploymentName" \
                                --no-prompt true --no-wait \
                                --template-uri "$EnvironmentTemplateUrlSecure" \
                                --parameters "$EnvironmentTemplateParametersJson"

    if [ $? -eq 0 ]; then # deployment successfully created

        while true; do

            sleep 5

            ProvisioningState=$(az deployment group show --resource-group "$EnvironmentResourceGroup" --name "$EnvironmentDeploymentName" --query "properties.provisioningState" -o tsv)
            ProvisioningDetails=$(az deployment operation group list --resource-group "$EnvironmentResourceGroup" --name "$EnvironmentDeploymentName")

            track "$ProvisioningDetails"
            
            if [[ "CANCELED|FAILED|SUCCEEDED" == *"${ProvisioningState^^}"* ]]; then

                    echo "Deployment $EnvironmentDeploymentName: $ProvisioningState"
                    break
            fi

        done
    fi
fi

tail -f /dev/null

