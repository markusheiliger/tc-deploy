#!/bin/bash

trace() {
    echo ">>> $@ ..."
}

trace "Initializing Terraform"
terraform init

trace "Applying Terraform Plan"
terraform apply -auto-approve -var "EnvironmentResourceGroupName=$EnvironmentResourceGroup"

tail -f /dev/null
