#!/bin/bash

cardano-cli address key-gen \
  --verification-key-file shelley-policy1.vkey \
  --signing-key-file shelley-policy1.skey

POLICY_ONE_PKH=$(cardano-cli address key-hash --payment-verification-key-file shelley-policy1.vkey) \
  && POLICY_ONE_PKH=${POLICY_ONE_PKH:0:56} \
  && echo "POLICY_ONE_PKH=\"$POLICY_ONE_PKH\""

cat << EOF > shelley-policy1.script
{
  "type": "all",
  "scripts":
  [
    {
      "type": "sig",
      "keyHash": "$POLICY_ONE_PKH"
    }
  ]
}
EOF

# Create Policy Id
POLICY_ID1=$(cardano-cli transaction policyid --script-file shelley-policy1.script) \
  && POLICY_ID1=${POLICY_ID1:0:56} \
  && echo "POLICY_ID1=\"$POLICY_ID1\""