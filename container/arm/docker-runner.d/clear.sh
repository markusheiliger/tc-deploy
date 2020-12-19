#!/bin/bash
DIR=$(dirname "$0")

trackDeploymentHistory=()

trackDeployment() { 

    $( echo "$1" | jq --raw-output '.[] | [.operationId, .properties.timestamp, .properties.provisioningOperation, .properties.provisioningState, .properties.targetResource.id // ""] | @tsv' ) | while read line; do
        if [[ ! -z "$line" ] && [ "${trackDeploymentHistory[@]}" == *"$line"* ]]; then

            timestamp=$( echo "$line" | cut -f 2 | cut -d . -f 1 | sed 's/T/ /g' )
            operation=$( echo "$line" | cut -f 3 )
            operationState=$( echo "$line" | cut -f 4 )
            operationTarget=$( echo "$line" | cut -f 5 )

            echo "\n$timestamp\t$operaton ($operationState)"
            
            if [[ ! -z "$operationTarget" ]]; then
                echo "\t\t$operationTarget"
            fi

            trackDeploymentHistory+=("$l")

        fi
    done

}

deleteResourceGroup() {

    EnvironmentDeploymentName="$(uuidgen)"
    EnvironmentResourceGroup="$1" 
    
    echo -e "Deleting resource group: $EnvironmentResourceGroup"

    DeploymentOutput=$(az deployment group create   --resource-group "$EnvironmentResourceGroup" \
                                                    --name "$EnvironmentDeploymentName" \
                                                    --no-prompt true --no-wait --mode Complete \
                                                    --template-file "$DIR/clear.json" 2>&1)

    if [ $? -eq 0 ]; then # deployment successfully created

        while true; do

            sleep 1

            ProvisioningState=$(az deployment group show --resource-group "$EnvironmentResourceGroup" --name "$EnvironmentDeploymentName" --query "properties.provisioningState" -o tsv)
            ProvisioningDetails=$(az deployment operation group list --resource-group "$EnvironmentResourceGroup" --name "$EnvironmentDeploymentName")

            trackDeployment "$ProvisioningDetails"
            
            if [[ "CANCELED|FAILED|SUCCEEDED" == *"${ProvisioningState^^}"* ]]; then

                echo "Deployment $EnvironmentDeploymentName: $ProvisioningState"
                break
            fi

        done
    fi

    if [ ! -z "$DeploymentOutput" ]; then

        if [ $(echo "$DeploymentOutput" | jq empty > /dev/null 2>&1; echo $?) -eq 0 ]; then

            DeploymentOutput="$( echo $DeploymentOutput | jq --raw-output '.[] | .details[] | "Error: \(.message)\n"' | sed 's/\\n/\n/g'  )"

        fi

        echo "$DeploymentOutput" && exit 1 # our script failed to enqueue a new deployment - we return a none zero exit code to inidicate this

    fi
}

if [ -z "$EnvironmentResourceGroup" ]; then

    $(az group list --query "[].name" -o tsv) | while read rg; do
        deleteResourceGroup "$rg"
    done

else

    deleteResourceGroup "$EnvironmentResourceGroup"

fi
