#!/bin/bash
source .exp

if [ ! -f $1.vkey ]  || [ ! -f $1.skey ]; then
   cardano-cli address key-gen --verification-key-file $1.vkey --signing-key-file $1.skey
else
   echo "Keys already there"
fi

if [ ! -f $1.addr ]; then
   cardano-cli address build --verification-key-file $1.vkey --out-file $1.addr $NETWORK
   echo "Address generated!" && cat $1.addr
else
   echo "Address already created"
fi
