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

### 2a. Configure `static-nodes.json` for your initial cluster
Let's say you want to bring up a cluster of three nodes, then in each node, the `qdata/static-nodes.json` file need to have the enode information of all the nodes in your initial cluster. Example:
```
[
"enode://26e80451f629db9249cf1f325e1346863532987ec816103b3ef64d193b213786d80837dfebfd5d42ec05ed755c0e520739808fe9134efb350b7bbf9cb8fc5d06@13.76.162.67:21000?discport=0&raftport=23000",
"enode://90c9b06bc504b19b3e187244c8a364eeb84d6a1af26ffbba568a74172abcc24bf5f54f5ddfd766cba970637b096dca1313d693a221c4e32782cf0a5766d36304@52.187.50.244:21000?discport=0&raftport=23000",
"enode://6b4f32ec54afba2c6190b460a68c4157f3778778ebec15d1c0c5a4c36ba3f87bb2eed3ebc9efc7eb8e776f037056c71bc28d71dae829b8b4501411c88cec52e9@52.187.127.171:21000?discport=0&raftport=23000"
]
```
Note that the order of the enodes in the `static-nodes.json` file need to be the same across all peers. So it is best to just copy the same file over all the nodes.

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

## 5. Add peer using raft dynamic membership (optional)
1. Login to geth console of any node of your existing cluster by
`(sudo) geth attach qdata/geth.ipc`
then do
`raft.addPeer($enodeInfo)`
where enodeInfo is the new node you wish to add (N.B. YOU HAVE TO USE PUBLIC IP IN THE ENODEINFO).
The `addPeer` command will return the `raftId` of your new node.
2. In the new node you want to bring up, do step (1) and (2), but skip (2a).
3. Copy the genesis file from the existing cluster to the new node, then do step (3).
4. Point your constellation to the existing cluster by configuring the `tm.conf` file in your new node.
5. Change the `raft-start.sh` script by adding `--raftjoinexisting $raftId` to the geth starting command. Example:
```
PRIVATE_CONFIG=tm.conf nohup geth --datadir qdata $GLOBAL_ARGS --rpccorsdomain "*" --rpcport 22000 --port 21000 --raftport 23000 --unlock 0 --password passwords.txt --raftjoinexisting 4 2>>qdata/logs/geth.log &
```
6. Now you can do step (4) as usual

Note that in the new node, your accounts is not funded as they were not funded in the exisiting cluster's `genesis.json` file. 
You will need to fund it from a pre-funded account in your existing cluster. Example:
```
eth.sendTransaction({from:eth.accounts[0], to:"0x2c80eba934fa0dee778fd0029bcd77a2cd31959e", value:1e25})
```

## 6. Checking connectivity
Now you can check peer connectivity by typing `admin.peers` in each nodes' geth console.

You can also do a test transaction with your default account by
```
eth.sendTransaction({from:eth.accounts[0]})
```

To test whether constellation is working, do a test private transaction. Example:
```
eth.sendTransaction({from:eth.accounts[0], privateFor:["o6vTfgeXqQ3Fc4KVFzt9vSYQTHbBjVwIjt5t33xLYjU="]})
```

## 7. If something goes wrong..
First stop all instances by `(sudo) ./stop.sh`. 
Wipe out chain data and reinitialize simply by `(sudo) ./raft-init.sh`.
Then do step (4) and (5).
