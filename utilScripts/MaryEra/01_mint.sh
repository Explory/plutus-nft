#!/bin/bash

SHELLEY_ADDR="addr_test1vz78hrllfzt53zvd6ym40k2lpeemkkqv9x79zq6u4ljqm7qh6hy5w"
TESTNET_MAGIC=1097911063
POLICY_ID1="4a0f37cd766e7bc8b62df915b9d2b97a7e5e4130067662c65ae26fb4"
EXP_ADDR="addr_test1vr67uxral3zvq5txnd5jt7xwwf70klcvas3egrsx5cx5z5ghcghul"
TX_IN1="802935f2f5d95213e94c0efcb9c53d974d9dc3652cb0f008f275cb0fe6651b4e#0"

SEND_AMOUNT=1500000

ASSET_NAME=MaryEXP
ASSET_AMOUNT=5000000000
#TO BURN TOKENS just add a minus to --mint parameter:  e.g. --mint "-$ASSET_AMOUNT $POLICY_ID1.$ASSET_NAME"

# Build, sign and submit the transaction
cardano-cli transaction build \
  --alonzo-era \
  --testnet-magic $TESTNET_MAGIC \
  --tx-in $TX_IN1 \
  --tx-out "$EXP_ADDR+$SEND_AMOUNT+$ASSET_AMOUNT $POLICY_ID1.$ASSET_NAME" \
  --mint "$ASSET_AMOUNT $POLICY_ID1.$ASSET_NAME" \
  --mint-script-file shelley-policy1.script \
  --witness-override 2 \
  --change-address $SHELLEY_ADDR \
  --out-file mtx.raw \
&& cardano-cli transaction sign \
  --tx-body-file mtx.raw \
  --signing-key-file /home/vagrant/cardano/keys/test.skey \
  --signing-key-file shelley-policy1.skey \
  --testnet-magic $TESTNET_MAGIC \
  --out-file mtx.signed \
&& cardano-cli transaction submit \
  --tx-file mtx.signed \
  --testnet-magic $TESTNET_MAGIC