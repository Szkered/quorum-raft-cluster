# Setup

## 1. Prepare dependency
`(sudo) ./get-quorum.sh`


## 2. Generate setup files
`(sudo) ./raft-setup.sh`
Password is stored in password.txt

Before doing step (3), you will need to properly configure `genesis.json`.
First repeat (1) and (2) for all the machine in your cluster, then prefund all the
default accounts in the genesis block correctly.

## 3. Init chain with setup files
`(sudo) ./raft-init.sh`
