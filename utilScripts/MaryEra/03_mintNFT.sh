#!/bin/bash

#$1 = NFT NAME 

NETWORK="--testnet-magic 1097911063"
MY_ADDR=$(cat /home/vagrant/explorie/wallets/explorieMain.addr)
CHANGE_ADDR=$MY_ADDR
LOVELACE=1400000
TOKEN_NAME=$1
TOKEN_AMOUNT=1
DIR_POLICY=policy
DIR_TOKEN="$DIR_POLICY/tokens/$TOKEN_NAME"
mkdir -p $DIR_TOKEN

if [ ! -f $DIR_POLICY/policy.vkey ]; then
    # Create policy keys
    cardano-cli address key-gen \
    --verification-key-file $DIR_POLICY/policy.vkey \
    --signing-key-file $DIR_POLICY/policy.skey
fi

POLICY_VKEY_HASH=$(cardano-cli address key-hash --payment-verification-key-file $DIR_POLICY/policy.vkey)
POLICY_SCRIPT=$DIR_TOKEN/token_policy.script

# Create policy script
cat << EOF > $POLICY_SCRIPT
{
    "type": "all",
    "scripts": [
        {
            "keyHash": "$POLICY_VKEY_HASH",
            "type": "sig"
        }
    ]
}
EOF

# Create policy id
cardano-cli transaction policyid --script-file $DIR_TOKEN/token_policy.script > $DIR_TOKEN/policy.id
POLICY_ID=$(cat $DIR_TOKEN/policy.id)
TOKEN_META=$DIR_TOKEN/token_meta.json

# Create metadata
echo "{" > $TOKEN_META
echo "\t\"721\": {" >> $TOKEN_META
echo "\t\t\"$POLICY_ID\": {" >> $TOKEN_META
## start tokens
while IFS= read -r line; do
    echo $line >> $TOKEN_META
done < metadata.txt
## end tokens
echo "\t\t}" >> $TOKEN_META
echo "\t}" >> $TOKEN_META
echo "}" >> $TOKEN_META


cardano-cli query utxo $NETWORK --address $MY_ADDR

read -p "Enter UTxO from above list: " MY_UTXO
read -p "Enter recepient address: " RCPT_ADDR

echo "Current slot:" && cardano-cli query tip $NETWORK | grep slot
read -p "Enter until which slot minting is aproved: " INVALID_AFTER_SLOT

## Build tx from address
echo "Building Mint Tx ..."
cardano-cli transaction build \
--alonzo-era \
--tx-in $MY_UTXO \
--tx-out $RCPT_ADDR+$LOVELACE+"$TOKEN_AMOUNT $POLICY_ID.$TOKEN_NAME" \
--mint="$TOKEN_AMOUNT $POLICY_ID.$TOKEN_NAME" \
--mint-script-file $POLICY_SCRIPT \
--metadata-json-file $TOKEN_META \
--tx-in-collateral $MY_UTXO \
--change-address $CHANGE_ADDR \
--invalid-hereafter=$INVALID_AFTER_SLOT \
$NETWORK \
--out-file tx.build
echo "Done."

# Sign tx
echo "Sign Tx ..."
cardano-cli transaction sign \
--signing-key-file /home/vagrant/explorie/wallets/explorieMain.skey \
--signing-key-file $DIR_POLICY/policy.skey \
--tx-body-file tx.build \
--out-file tx.sign
echo "Done."

# Submit tx
echo "Submiting Tx ..."
cardano-cli transaction submit $NETWORK --tx-file tx.sign