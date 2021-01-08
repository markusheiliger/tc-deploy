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

    trace "Stopping & deallocating VM resources"
    az vm deallocate --ids {vms_ids}

fi