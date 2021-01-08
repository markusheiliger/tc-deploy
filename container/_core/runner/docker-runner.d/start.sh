#!/bin/bash

DIR=$(dirname "$0")

trace() {
    echo -e "\n>>> $@ ...\n"
}

VMResourceIds=""

if [ -z "$EnvironmentResourceGroup" ]; then
    VMResourceIds=$(az vm list --subscription $EnvironmentSubscription --query "[].id" -o tsv)
else
    VMResourceIds=$(az vm list --subscription $EnvironmentSubscription -g $EnvironmentResourceGroup --query "[].id" -o tsv)
fi

if [[ ! -z "$VMResourceIds" ]]; then

    trace "Starting VM resources"
    az vm start --ids {vms_ids}

fi