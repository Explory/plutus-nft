#!/bin/bash
POLICY_EXP=$(cardano-cli transaction policyid --script-file $(pwd)/../mintTokens/plutus-scripts/mint-exp-tokens.plutus)
TX_IN="35a5fe48abf6d0d10c631ad1d39bed361566d9a3c5591b8ce12d1ee1e61977d1#0"
TX_COL="35a5fe48abf6d0d10c631ad1d39bed361566d9a3c5591b8ce12d1ee1e61977d1#0"
SEND_AMOUNT=1500000
ASSET_NAME=TEXP
ASSET_AMOUNT=6000000000

cardano-cli transaction build --alonzo-era --testnet-magic 1097911063 \
--tx-in $TX_IN --tx-in-collateral $TX_COL \
--mint "$ASSET_AMOUNT $POLICY_EXP.$ASSET_NAME" \
--mint-script-file /home/vagrant/plutus/git/plutus-nft/mintTokens/plutus-scripts/mint-exp-tokens.plutus \
--mint-redeemer-value $ASSET_AMOUNT \
--tx-out "$(cat ../wallets/explorieSecondary.addr)+$SEND_AMOUNT+$ASSET_AMOUNT $POLICY_EXP.$ASSET_NAME" \
--change-address $(cat ../wallets/explorieSecondary.addr) \
--protocol-params-file ../txs/protocol-params.json \
--out-file ../txs/tx.build

cardano-cli transaction sign \
--tx-body-file ../txs/tx.build \
--signing-key-file ../wallets/explorieSecondary.skey \
--testnet-magic 1097911063 \
--out-file ../txs/tx.signed

cardano-cli transaction submit --tx-file ../txs/tx.signed --testnet-magic 1097911063