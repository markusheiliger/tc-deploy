#!/bin/sh

trace() {
    echo ">>> $@ ..."
}


trace "Connecting Azure"
while true; do
    # managed identity isn't avaialble directly - retry
    az login --identity 2>/dev/null && {
        export ARM_USE_MSI=true
        export ARM_MSI_ENDPOINT='http://169.254.169.254/metadata/identity/oauth2/token'
        export ARM_SUBSCRIPTION_ID=$EnvironmentSubscription
        break
    } || sleep 5    
done

trace "Selecting subscription"
az account set --subscription $EnvironmentSubscription

trace "Initializing terraform"
echo "$(dirname $EnvironmentTemplate)" |  sed 's/file:\/\///' | cd && terraform init

trace "Applying terraform"
terraform apply -auto-approve -var "EnvironmentResourceGroupName=$EnvironmentResourceGroup"

tail -f /dev/null
