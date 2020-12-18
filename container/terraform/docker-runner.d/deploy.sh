#!/bin/bash

trace() {
    echo ">>> $@ ..."
}

trace "Initializing Terraform"
terraform init -no-color

trace "Applying Terraform Plan"
terraform apply -no-color -auto-approve -var "EnvironmentResourceGroupName=$EnvironmentResourceGroup"

# tail -f /dev/null
