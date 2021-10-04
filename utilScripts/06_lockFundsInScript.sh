#!/bin/bash

source .exp

#$1 TX_IN
#$2 TX_OUT+1ADA
#$3 DATUM_HASH
#$4 PAYMENT_ADDR
#$5 skey of payment addr

# Build, sign and submit the transaction
cardano-cli transaction build \
  --alonzo-era \
  $NETWORK \
  --tx-in $1 \
  --tx-out $2 \
  --tx-out-datum-hash $3 \
  --change-address $4 \
  --out-file stx.build \
&& cardano-cli transaction sign \
  --tx-body-file stx.build \
  --signing-key-file $5 \
  --out-file stx.signed \
&& cardano-cli transaction submit \
  --tx-file stx.signed \
  $NETWORK