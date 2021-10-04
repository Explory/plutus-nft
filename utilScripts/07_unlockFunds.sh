#!/bin/bash

source .exp

#$1 TX_SCRIPT
#$2 PLUTUS_SCRIPT
#$3 DATUM_VALUE
#$4 REDEEMER_VALUE (0)
#$5 TX_COLLATERAL
#$6 CHANGE_ADDRESS
#$7 PROTOCOL_FILE
#$8 SKEY Payment ADDR

# Build, sign and submit the transaction
cardano-cli transaction build \
  --alonzo-era \
  $NETWORK \
  --tx-in $1 \
  --tx-in-script-file $2 \
  --tx-in-datum-value $3 \
  --tx-in-redeemer-value $4 \
  --tx-in-collateral $5 \
  --change-address $6 \
  --protocol-params-file $7 \
  --out-file wtx.build \
&& cardano-cli transaction sign \
  --tx-body-file wtx.build \
  --signing-key-file $8 \
  --out-file wtx.signed \
&& cardano-cli transaction submit \
  --tx-file wtx.signed \
  $NETWORK