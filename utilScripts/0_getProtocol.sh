#!/bin/bash

source .env

cardano-cli query protocol-parameters $NETWORK > protocol-params.json