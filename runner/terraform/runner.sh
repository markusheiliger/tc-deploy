#!/bin/sh

trace() {
    echo ">>> $@ ..."
}

trace "Initializing downloads"
mkdir /templates && cd /templates

trace "Downloading template"
wget "$EnvironmentTemplateUri"

trace "Downloading artifacts"
for url in $*; do wget "${url}"; done

trace "Sanitizing downloads"
for file in $(find -type f -name "*\?*"); do mv $file $(echo $file | cut -d? -f1); done

trace "Connecting Azure"
while true; do
    # managed identity isn't avaialble directly - retry
    az login --identity 2>/dev/null && {
        export ARM_USE_MSI=true
        export ARM_MSI_ENDPOINT='http://169.254.169.254/metadata/identity/oauth2/token'
        export ARM_SUBSCRIPTION_ID=$EnvironmentResourceGroupSubscription
        break
    } || sleep 5    
done

trace "Selecting subscription"
az account set --subscription $EnvironmentResourceGroupSubscription

trace "Initializing Terraform"
terraform init

trace "Applying Terraform"
terraform apply -auto-approve -var "EnvironmentResourceGroupName=$EnvironmentResourceGroupName"

tail -f /dev/null
