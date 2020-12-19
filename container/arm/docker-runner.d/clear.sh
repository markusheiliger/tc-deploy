#!/bin/bash

deleteResourceGroup() {

    echo -e "\n>>> Deleting resource group: $1"
    echo -e "\nDeleting locks ..." && az lock delete -g $1
    echo -e "\nDeleting resources ..." && az group delete -g $1 -y

}

if [ -z "$EnvironmentResourceGroup" ]; then

    $(az group list --query "[].name" -o tsv) | while read rg; do
        deleteResourceGroup "$rg"
    done

else

    deleteResourceGroup "$EnvironmentResourceGroup"

fi


