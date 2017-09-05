#!/bin/bash
set -u
set -e

echo "[*] Cleaning up temporary data directories"
rm -rf qdata
mkdir -p qdata/logs

echo "[*] Configuring node"
mkdir -p qdata/{keystore,geth}
cp raft/static-nodes.json qdata
# cp raft/keystore/$(ls raft/keystore) qdata/keystore/acckey
cp raft/geth/nodekey qdata/geth/nodekey
geth --datadir qdata init genesis.json

echo "[*] Creating default ethereum account"
geth --datadir qdata --password passwords.txt account new
killall geth
