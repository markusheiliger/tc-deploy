#!/bin/bash

DIR=$(dirname "$0")

# isolate task script execution in sub shell  
( exec "$DIR/delete.sh"; exit $? ) || exit $?
