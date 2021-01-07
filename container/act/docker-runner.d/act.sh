#!/bin/bash
DIR=$(dirname "$0")

trace() {
    echo ">>> $@ ..."
}

act $DeploymentType --workflows $DIR

tail -f /dev/null
