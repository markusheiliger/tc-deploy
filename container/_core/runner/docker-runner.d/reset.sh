#!/bin/bash

DIR=$(dirname "$0")

# isolate task script execution in sub shell  
( exec "$DIR/create.sh"; exit $? ) || exit $?
