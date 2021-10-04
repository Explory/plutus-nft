#!/bin/bash

# arguments:
#   utxo (NFT)
#   utxo (collateral)
#   wallet address file
#   signing key file
export CARDANO_NODE_SOCKET_PATH=node.socket

source ../../utilScripts/.exp

bodyFile=explorie-tx-body.02
outFile=explorie-tx.02
nftPolicyFile="../plutus-scripts/mint-nft-policy.plutus"
nftPolicyId=$(../../utilScripts/09_createPolicyScript.sh $nftPolicyFile)
value="1724100 lovelace + 1 $nftPolicyId.ExplorieNFT"
walletAddr=$(cat $3)
scriptAddr=$(../../utilScripts/05_createScript.sh .plutus)

echo "utxoNFT: $1"
echo "utxoCollateral: $2"
echo "bodyFile: $bodyFile"
echo "outFile: $outFile"
echo "nftPolicyFile: $nftPolicyFile"
echo "nftPolicyId: $nftPolicyId"
echo "value: $value"
echo "walletAddress: $walletAddr"
echo "scriptAddress: $scriptAddr"
echo "signing key file: $4"
echo

echo

./cardano-cli transaction build \
    --alonzo-era \
    $NETWORK \
    --tx-in $1 \
    --tx-in $2 \
    --tx-in-collateral $2 \
    --tx-out "$scriptAddr + $value" \
    --tx-out-datum-hash 45b0cfc220ceec5b7c1c62c4d4193d38e4eba48e8815729ce75f9c0ab0e4c1c0 \
    --change-address $walletAddr \
    --protocol-params-file mainnet-protocol-parameters.json \
    --out-file $bodyFile

echo "saved transaction to $bodyFile"

./cardano-cli transaction sign \
    --tx-body-file $bodyFile \
    --signing-key-file $4 \
    $NETWORK \
    --out-file $outFile

echo "signed transaction and saved as $outFile"

./cardano-cli transaction submit \
    $NETWORK \
    --tx-file $outFile

echo "submitted transaction"

echo