#!/bin/sh

set -e

trace() {
    echo -e "\n>>> $@ ...\n"
}

nginx 

find "/docker-entrypoint.d/" -follow -type f -iname "*.sh" -print | sort -n | while read -r f; do
    if [ -x "$f" ]; then trace "Running '$f'"; "$f"; fi
done

if [[ ! -z "$EnvironmentTemplateFile" ]]; then

    trace "Selecting template directory"
    cd $(echo "$(dirname $EnvironmentTemplateFile)" | sed 's/^file:\/\///') && echo $PWD
fi

if [[ ! -z "$EnvironmentSubscription" ]]; then

    trace "Connecting Azure"
    az login --identity && {
        export ARM_USE_MSI=true
        export ARM_MSI_ENDPOINT='http://169.254.169.254/metadata/identity/oauth2/token'
        export ARM_SUBSCRIPTION_ID=$EnvironmentSubscription
    }

    az account set --subscription $EnvironmentSubscription && \
    az account show
fi

if [[ ! -z "$@" ]]; then
    
    trace "Executing deployment"
    exec "$@"
fi
