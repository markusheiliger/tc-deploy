#!/bin/bash

trackDeployment() { 

    trace="$( echo "$1" | jq --raw-output '.[] | select(.properties.targetResource != null) | "\(.properties.targetResource.id)\nOperation: \(.properties.provisioningOperation)\nStatus: \(.properties.provisioningState)\n"' | sed 's/\\n/\n/g' )" 

    # echo "=========================================================================="    
    # echo "$1"
    # echo "--------------------------------------------------------------------------"    
    
    echo -e "$trace\n"

}

EnvironmentDeploymentName="$(uuidgen)"
EnvironmentTemplateFile="$(echo "$EnvironmentTemplateFolder/azuredeploy.json" | sed 's/^file:\/\///g')"
EnvironmentTemplateUrl="$(echo "$EnvironmentTemplateBaseUrl/azuredeploy.json" | sed 's/^http:/https:/g')"
EnvironmentTemplateParametersJson=$(echo "$EnvironmentTemplateParameters" | jq --compact-output '{ "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#", "contentVersion": "1.0.0.0", "parameters": (to_entries | if length == 0 then {} else (map( { (.key): { "value": .value } } ) | add) end) }' )
EnvironmentTemplateParametersOpts=()

$(cat "$EnvironmentTemplateFile" | jq --raw-output '.parameters | to_entries[] | select( .key | startswith("_artifactsLocation")) | .key' ) | while read p; do
    case "$p" in
        _artifactsLocation)
            EnvironmentTemplateParametersOpts+=( --parameters _artifactsLocation="$(dirname EnvironmentTemplateUrl)" )
            ;;
        _artifactsLocationSasToken)
            EnvironmentTemplateParametersOpts+=( --parameters _artifactsLocationSasToken="?code=$EnvironmentTemplateUrlToken" )
            ;;
    esac
done

DeploymentOutput=""

if [ -z "$EnvironmentResourceGroup" ]; then

    DeploymentOutput=$(az deployment sub create --location "$EnvironmentLocation" \
                                                --name "$EnvironmentDeploymentName" \
                                                --no-prompt true --no-wait \
                                                --template-uri "$EnvironmentTemplateUrl" \
                                                --parameters "$EnvironmentTemplateParametersJson" \
                                                "${EnvironmentTemplateParametersOpts[@]}" 2>&1)

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

    DeploymentOutput=$(az deployment group create   --resource-group "$EnvironmentResourceGroup" \
                                                    --name "$EnvironmentDeploymentName" \
                                                    --no-prompt true --no-wait \
                                                    --template-uri "$EnvironmentTemplateUrl" \
                                                    --parameters "$EnvironmentTemplateParametersJson" 2>&1)

    if [ $? -eq 0 ]; then # deployment successfully created

        while true; do

            sleep 5

            ProvisioningState=$(az deployment group show --resource-group "$EnvironmentResourceGroup" --name "$EnvironmentDeploymentName" --query "properties.provisioningState" -o tsv)
            ProvisioningDetails=$(az deployment operation group list --resource-group "$EnvironmentResourceGroup" --name "$EnvironmentDeploymentName")

            trackDeployment "$ProvisioningDetails"
            
            if [[ "CANCELED|FAILED|SUCCEEDED" == *"${ProvisioningState^^}"* ]]; then

                    echo "Deployment $EnvironmentDeploymentName: $ProvisioningState"
                    break
            fi

        done
    fi
fi

if [ ! -z "$DeploymentOutput" ]; then

    if [ $(echo "$DeploymentOutput" | jq empty > /dev/null 2>&1; echo $?) -eq 0 ]; then

        echo "DeploymentOutput: $DeploymentOutput"
        $DeploymentOutput="$( echo $DeploymentOutput | jq --raw-output '.[] | .details[] | "Error: \(.message)\n"' | sed 's/\\n/\n/g' )"
    fi

    echo "$DeploymentOutput" && exit 1 # our script failed to enqueue a new deployment - we return a none zero exit code to inidicate this

fi

# tail -f /dev/null

