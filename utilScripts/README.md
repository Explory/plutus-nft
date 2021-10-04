# How to run the scripts

#Pre-required
Modify .exp for your need
### can add mainnet instead

## 00_createWallet.sh

`bash 00_createWallet.sh /path/where/you/want/to/save/the/keys/nameOfTheKey`

generates => 
    - nameOfTheKey.vkey 
    - nameOfTheKey.skey
    - nameOfTheKey.addr

## 01_checkWallet.sh

`bash 01_checkWallet.sh addr` 

if no addr is given a default addr is picked

## 02_getUtxo.sh

Get first UTXO (the 3rd row): 

`bash 02_getUtxo.sh $(cat ../wallets/explorieMain.addr)`

this is similar to:

`bash 02_getUtxo.sh $(cat ../wallets/explorieMain.addr) 3`

if you need other UTXO change the number (e.g. for second UTXO)

`bash 02_getUtxo.sh $(cat ../wallets/explorieMain.addr) 4`

give as parameter the mainnet/testnet and the address of the wallet. Add it to a variable:
`ADDR=$(bash 02_getUtxo.sh $(cat ../wallets/explorieMain.addr))`

## 03_makeTransaction.sh

transfer 10 ADA from our account to payment.addr
`bash 03_makeTransaction.sh $(bash 02_getUtxo.sh $(cat ../wallets/explorieMain.addr)) payment.addr+10000000 $(cat ../wallets/explorieMain.addr) ../wallets/explorieMain.skey`

## 04_createDatumHash.sh

create datum hash and value from a string
`bash 04_createDatumHash.sh 'mystring'`

## 05_createScript.sh

create scripts.addr from a plutus script
`bash 05_createScript.sh /path/to/plutus/script`

## 06_lockFundsInScript.sh

lock funds from Explorie wallet to the script address with the datum hash something

`bash 06_lockFundsInScript.sh $(bash 02_getUtxo.sh $(cat ../wallets/explorieMain.addr))  script.addr+10000000 $(bash 04_createDatumHash.sh 'something') $(cat ../wallets/explorieMain.addr) ../wallets/explorieMain.skey`

## 07_unlockFunds.sh

unlock funds from the script address

`bash 07_unlockFunds.sh script#UTXO /path/to/plutus/script.plutus DATUM_VALUE 0 coll#UTXO payment.addr protocol.json payment.skey`

