#!/bin/bash

# arguments:
#   utxo
#   wallet address file
#   path metadata.json
#   signing key file

if [ $# != 4 ]; then
    echo "please give the 4 parameters"
    exit;
fi

source ../../utilScripts/.exp

export CARDANO_NODE_SOCKET_PATH=node.socket

bodyFile=explorie-tx-body.01
outFile=explorie-tx.01
nftPolicyFile="../plutus-scripts/mint-nft.plutus"
nftPolicyId=$(../../utilScripts/09_createPolicyScript.sh $nftPolicyFile)
value="1 $nftPolicyId.ExplorieNFT"
walletAddr=$(cat $2)

echo "utxo: $1"
echo "bodyFile: $bodyFile"
echo "outFile: $outFile"
echo "nftPolicyFile: $nftPolicyFile"
echo "nftPolicyId: $nftPolicyId"
echo "value: $value"
echo "walletAddress: $walletAddr"
echo "signing key file: $3"
echo

echo

cardano-cli transaction build \
    --alonzo-era \
    $NETWORK \
    --tx-in $1 \
    --tx-in-collateral $1 \
    --tx-out $walletAddr" + 1724100 lovelace + "$value \
    --tx-out-datum-hash 45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0 \
    --mint "$value" \
    --mint-script-file $nftPolicyFile \
    --mint-redeemer-value [] \
    --change-address $walletAddr \
    --metadata-json-file $3 \
    --protocol-params-file mainnet-protocol-parameters.json \
    --out-file $bodyFile

echo "saved transaction to $bodyFile"

cardano-cli transaction sign \
    --tx-body-file $bodyFile \
    --signing-key-file $4 \
    $NETWORK \
    --out-file $outFile

echo "signed transaction and saved as $outFile"

cardano-cli transaction submit \
    $NETWORK \
    --tx-file $outFile

echo "submitted transaction"

echo