#!/bin/bash

POLICY=$(cardano-cli transaction policyid --script-file $1) && echo $POLICY