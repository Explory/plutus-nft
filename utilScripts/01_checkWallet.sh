#!/bin/bas

source .env

explorieAddr=addr_test1vr67uxral3zvq5txnd5jt7xwwf70klcvas3egrsx5cx5z5ghcghul

if [ $# -eq 1 ]; then
  explorieAddr=$1
fi

cardano-cli query utxo $NETWORK --address $explorieAddr

