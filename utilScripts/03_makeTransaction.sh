#!/bin/bash

source .env

# build
cardano-cli transaction build --alonzo-era $NETWORK --tx-in $1 --tx-out $2 --change-address $3 --out-file tx.build
echo "transaction is built" && ls -la tx.build

# sign
cardano-cli transaction sign $NETWORK --signing-key-file $4 --tx-body-file tx.build --out-file tx.sign
echo "transaction is signed" && ls -la tx.sign

# submit
cardano-cli transaction submit $NETWORK --tx-file tx.sign
echo "transaction is submitted"
