#!/bin/sh

trace() {
    echo ">>> $@ ..."
}

trace "Selecting template directory"
cd $(echo "$(dirname $EnvironmentTemplate)" | sed 's/^file:\/\///') && echo $PWD

trace "Connecting Azure"
while true; do
    # managed identity isn't avaialble directly - retry
    az login --identity --output none 2>/dev/null && {
        export ARM_USE_MSI=true
        export ARM_MSI_ENDPOINT='http://169.254.169.254/metadata/identity/oauth2/token'
        export ARM_SUBSCRIPTION_ID=$EnvironmentSubscription
        az account set --subscription $EnvironmentSubscription
        az account show
        break
    } || sleep 5    
done



tail -f /dev/null
