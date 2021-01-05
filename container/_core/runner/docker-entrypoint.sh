#!/bin/bash

set -e
trap 'catch $? $LINENO' EXIT

catch() {
  if [ "$1" != "0" ]; then
    # error handling goes here
    echo "Error $1 occurred on $2"
  fi
}

trace() {
    echo -e "\n>>> $@ ...\n"
}

error() {
    echo "Error: $@" 1>&2
}

if [[ ! -z "$DeploymentHost" ]]; then
    sed -i "s/server_name.*/server_name $DeploymentHost;/g" /etc/nginx/conf.d/default.conf
    nginx # start nginx and acquire SSL certificate from lets encrypt for our hostname
    certbot --nginx --register-unsafely-without-email --agree-tos --quiet -n -d $DeploymentHost
fi

find "/docker-entrypoint.d/" -follow -type f -iname "*.sh" -print | sort -n | while read -r f; do
    # execute each shell script found enabled for execution
    if [ -x "$f" ]; then trace "Running '$f'"; "$f"; fi
done

if [[ ! -z "$EnvironmentTemplateFolder" ]]; then
    trace "Selecting template directory"
    cd $(echo "$EnvironmentTemplateFolder" | sed 's/^file:\/\///') && echo $PWD
fi

if [[ ! -z "$EnvironmentSubscription" ]]; then

    trace "Connecting Azure"
    while true; do
        # managed identity isn't available directly - retry after a short nap
        az login --identity --only-show-errors 2>/dev/null && {
            export ARM_USE_MSI=true
            export ARM_MSI_ENDPOINT='http://169.254.169.254/metadata/identity/oauth2/token'
            export ARM_SUBSCRIPTION_ID=$EnvironmentSubscription
            break
        } || sleep 5    
    done

    trace "Selecting Subscription"
    az account set --subscription $EnvironmentSubscription
    echo "$(az account show -o json | jq --raw-output '"\(.name) (\(.id))"')"

fi

script="$@" # we start with the script provided by docker CMD

if [[ -z "$@" ]]; then

    # if no script was provided via command arguments we need to fallback 
    # to the deployment type based runner script located in /docker-runner.d
    script="$(find /docker-runner.d -maxdepth 1 -iname "$DeploymentType.sh")"

    if [[ -z "$script" ]]; then 
        # there is no scipt availabe to handle our deployment type
        error "Deployment type $DeploymentType is not supported." && exit 1
    fi
    
fi

trace "Executing script"
exec "$script"
