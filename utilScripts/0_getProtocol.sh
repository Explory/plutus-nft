#!/bin/bash

source .exp

cardano-cli query protocol-parameters $NETWORK > protocol-params.json