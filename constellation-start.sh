#!/bin/bash
set -u
set -e

echo "[*] Starting Constellation node"
nohup constellation-node tm.conf 2>> qdata/logs/constellation.log &
