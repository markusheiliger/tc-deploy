#!/bin/sh

set -e

trace() {
    echo -e "\n>>> $@ ...\n"
}

find "/docker-entrypoint.d/" -follow -type f -iname "*.sh" -print | sort -n | while read -r f; do
    if [ -x "$f" ]; then trace "Running '$f'"; "$f"; fi
done

trace "Starting template host"
nginx & ps -p $!

if [[ ! -z "$EnvironmentTemplate" ]]; then

    trace "Selecting template directory"
    cd $(echo "$(dirname $EnvironmentTemplate)" | sed 's/^file:\/\///') && echo $PWD
fi

if [[ ! -z "$EnvironmentSubscription" ]]; then

    trace "Connecting Azure"
    while true; do
        # managed identity isn't avaialble directly - retry
        az login --identity --output none 2>/dev/null && {
            export ARM_USE_MSI=true
            export ARM_MSI_ENDPOINT='http://169.254.169.254/metadata/identity/oauth2/token'
            export ARM_SUBSCRIPTION_ID=$EnvironmentSubscription
            break
        } || sleep 5    
    done

    trace "Initializing Azure"
    az account set --subscription $EnvironmentSubscription && \
    
    az account show
fi

if [[ ! -z "$@" ]]; then
    
    trace "Executing deployment"
    exec "$@"
fi
