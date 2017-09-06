# Steps

## 1. Prepare dependency
`(sudo) ./get-quorum.sh`


## 2. Generate setup files
`(sudo) ./raft-setup.sh`
Password is stored in password.txt

Before doing step (3), you will need to prefund all the account used for smart contract
by properly configuring `genesis.json`.
First repeat (1) and (2) for all the machine in your cluster, then prefund all the
default accounts in the genesis block as follows:

In the alloc section of your genesis file, fund all your account with some ether
balance. Let's say you have account `"6e4949d29fe2eee9007e4f5d6127b09e1eb98d15"`
in node1 and `"93ceb2a9e1ddc216de9befd994bf303e88379e2b"` in node2, then you will
have:
```
  "alloc": {
    "6e4949d29fe2eee9007e4f5d6127b09e1eb98d15": {
      "balance": "1000000000000000000000000000"
    },
    "93ceb2a9e1ddc216de9befd994bf303e88379e2b": {
      "balance": "1000000000000000000000000000"
    }
  },
```
This genesis file need to be the same across all the node in your cluster.

Alternatively, you can have only one prefunded account in your `genesis.json`,
say node1's default account, and send out ether balance from that account
to all other nodes' account.

## 3. Init chain with setup files
`(sudo) ./raft-init.sh`

## 4. Start your instances
Before you start the instance, please configure `othernodes` field in your `tm.conf`
file, which should contain the public ip of all other nodes you want to connect to.
Then you can run
`(sudo) ./constellation-start.sh`
After inspecting the log and making sure that constellation nodes are properly connected,
you can start geth node by
`(sudo) ./raft-start.sh`

## 5. Add peer using raft dynamic membership
Login to geth console by
`(sudo) geth attach qdata/geth.ipc`
then do
`raft.addPeer($enodeInfo)`
where enodeInfo is what's inside static-nodes.json in each machine/instance.
N.B. YOU HAVE TO USE PUBLIC IP IN THE ENODEINFO.

Now you can check peer connectivity by typing `admin.peers` in each nodes' geth console.
You can also do a test transaction with your default account by
`eth.sendTransaction({from:eth.accounts[0]})`.

## 6. If something goes wrong..
First stop all instances by `(sudo) ./stop.sh`. 
Wipe out chain data and reinitialize simply by `(sudo) ./raft-init.sh`
Then do step (4) and (5)
