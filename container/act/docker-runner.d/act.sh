#!/bin/bash
# . /usr/local/bin/docker-wrapper.sh

readonly DIR=$(dirname "$0")
readonly EVENT_FILE="$DIR/$TaskId.event"

trace() {
    echo ">>> $@ ..."
}

trace "Starting docker daemon"
dockerd &

trace "Starting workflow"
echo "$ComponentTemplateParameters" | jq '{ "action": "workflow_dispatch", "input": . }' > $EVENT_FILE
act --job create --eventpath $EVENT_FILE --workflows $DIR

#tail -f /dev/null