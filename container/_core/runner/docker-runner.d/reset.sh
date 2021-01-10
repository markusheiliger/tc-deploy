#!/bin/bash

DIR=$(dirname "$0")
( exec "$DIR/create.sh"; exit $? ) || exit $?
