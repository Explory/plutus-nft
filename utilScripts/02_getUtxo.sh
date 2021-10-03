#!/bin/bash

source .env

line='3p'

if [ $# -eq 2 ]; then
  line=$3'p'
fi

cardano-cli query utxo $NETWORK --address $1 | sed -n $line | awk '{print $1 "#" $2}'