#!/bin/bash
. /usr/local/bin/docker-wrapper.sh

DIR=$(dirname "$0")

trace() {
    echo ">>> $@ ..."
}

readonly EVENT_FILE="$DIR/$DeploymentId.event"

echo "$EnvironmentTemplateParameters" | jq '{ "action": "workflow_dispatch", "input": . }' > $EVENT_FILE
act --job create --eventpath $EVENT_FILE --workflows $DIR

tail -f /dev/null