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

bodyFile=explorie-tx-body.01
outFile=explorie-tx.01
nftPolicyFile="../plutus-scripts/mint-nft-policy.plutus"
nftPolicyId=$(bash ../../utilScripts/09_createPolicyScript.sh $nftPolicyFile)
walletAddr=$(cat $2)
declare -A value

while read line; do
    # echo $line
    filenameend="$(echo $line | awk 'BEGIN { FS = "~" }; {print $1}' | sed 's/[ |'\'']/_/g')"
    pathToFile="$(pwd)/metadata/metadata_$filenameend.json"

    cp $3 $pathToFile
    NFT_NAME=$(echo $line | awk 'BEGIN { FS = "~" }; {print $1}')
    NFT_IPFS=$(echo $line | awk 'BEGIN { FS = "~" }; {print $2}')
    NFT_MT=$(echo $line | awk 'BEGIN { FS = "~" }; {print $3}')
    NFT_DESC=$(echo $line | awk 'BEGIN { FS = "~" }; {print $4}')
    NFT_GEO=$(echo $line | awk 'BEGIN { FS = "~" }; {print $5}')
    NFT_CO=$(echo $line | awk 'BEGIN { FS = "~" }; {print $6}')
    NFT_COL=$(echo $line | awk 'BEGIN { FS = "~" }; {print $7}')
    NFT_TYPE=$(echo $line | awk 'BEGIN { FS = "~" }; {print $8}')
    NFT_RARITY=$(echo $line | awk 'BEGIN { FS = "~" }; {print $9}')
    NFT_SUB=$(echo $line | awk 'BEGIN { FS = "~" }; {print $10}')

    value[$pathToFile]="1 $nftPolicyId.$NFT_NAME"

    echo ${value[$pathToFile]}

    sed -i "s/PLACEHOLDER_POLICY_ID/$nftPolicyId/g" $pathToFile
    sed -i "s/PLACEHOLDER_ASSET_NAME_KEY/$filenameend/g" $pathToFile
    sed -i "s/PLACEHOLDER_ASSET_NAME/$NFT_NAME/g" $pathToFile
    sed -i "s/PLACEHOLDER_IPFS/$NFT_IPFS/g" $pathToFile
    sed -i "s/PLACEHOLDER_MEDIA_TYPE/$NFT_MT/g" $pathToFile
    sed -i "s/PLACEHOLDER_DESCRIPTION/$NFT_DESC/g" $pathToFile
    sed -i "s/PLACEHOLDER_GEO_LOCATION/$NFT_GEO/g" $pathToFile
    sed -i "s/PLACEHOLDER_COMPANY/$NFT_CO/g" $pathToFile
    sed -i "s/PLACEHOLDER_COLLECTION/$NFT_COL/g" $pathToFile
    sed -i "s/PLACEHOLDER_TYPE/$NFT_TYPE/g" $pathToFile
    sed -i "s/PLACEHOLDER_RARITY/$NFT_RARITY/g" $pathToFile
    sed -i "s/PLACEHOLDER_SUBTITLE/$NFT_SUB/g" $pathToFile
    
    cat $pathToFile
    echo 
    echo 
done < ./populateNFTs.txt

echo "utxo: $1"
echo "bodyFile: $bodyFile"
echo "outFile: $outFile"
echo "nftPolicyFile: $nftPolicyFile"
echo "nftPolicyId: $nftPolicyId"
echo "value: ${value}"
echo "walletAddress: $walletAddr"
echo "metadata template: $3"
echo "signing key file: $4"
echo

for f in $(pwd)/metadata/*.json; do
    echo

    cardano-cli transaction build \
        --alonzo-era \
        $NETWORK \
        --tx-in $1 \
        --tx-in-collateral $1 \
        --tx-out "${walletAddr} + 1724100 lovelace + ${value[$f]}" \
        --mint "${value[$f]}" \
        --mint-script-file $nftPolicyFile \
        --mint-redeemer-value [] \
        --change-address $walletAddr \
        --metadata-json-file $f \
        --protocol-params-file ../../txs/protocol-params.json \
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
done
