#!/bin/sh

trace() {
    echo ">>> $@ ..."
}


while true; do
    # managed identity isn't avaialble directly - retry
    az login --identity --output none 2>/dev/null && {
        export ARM_USE_MSI=true
        export ARM_MSI_ENDPOINT='http://169.254.169.254/metadata/identity/oauth2/token'
        export ARM_SUBSCRIPTION_ID=$EnvironmentSubscription
        break
    } || sleep 5    
done

trace "Selecting target subscription"
az account set --subscription $EnvironmentSubscription && az account show

trace "Selecting template directory"
cd $(echo "$(dirname $EnvironmentTemplate)" | sed 's/^file:\/\///') && echo $PWD
