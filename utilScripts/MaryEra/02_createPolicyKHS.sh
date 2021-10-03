#!/bin/bash

## Create policy KHS - Keys Hash Script
## create policy for minting tokens (creates keys, hash and script => KHS)
## `bash 08_createPolicyKHS.sh /path/to/policiy/nameOfTheKHS`


if [ ! -f $1.vkey ]  || [ ! -f $1.skey ]; then
   cardano-cli address key-gen --verification-key-file $1.vkey --signing-key-file $1.skey
fi

POLICY_TWO_PKH=$(cardano-cli address key-hash --payment-verification-key-file $1.vkey) && POLICY_TWO_PKH=${POLICY_TWO_PKH:0:56}

cat << EOF > $1.script
{
  "type": "all",
  "scripts":
  [
    {
      "type": "sig",
      "keyHash": "$POLICY_TWO_PKH"
    }
  ]
}
EOF

# Create Policy Id
cardano-cli transaction policyid --script-file $1.script