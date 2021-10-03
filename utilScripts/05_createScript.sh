#!/bin/bash

source .env

#$1 .plutus script

cardano-cli address build \
    $NETWORK \
    --payment-script-file $1 \
    --out-file scritp.addr \
  && echo "$(cat script.addr)"