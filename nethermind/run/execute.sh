#!/bin/bash

/nethermind/nethermind \
    --datadir=/data/${TESTNET} \
    --Network.P2PPort=${EXECUTION_DISC} \
    --Network.DiscoveryPort=${EXECUTION_DISC} \
    --JsonRpc.Enabled=true \
    --JsonRpc.Host=0.0.0.0 \
    --JsonRpc.Port=8545 \
    --JsonRpc.JwtSecretFile=/execution-auth.jwt \
    --JsonRpc.EngineHost=0.0.0.0 \
    --JsonRpc.EnginePort=8551 \
    --Metrics.Enabled=true \
    --Metrics.NodeName=nethermind-${TESTNET} \
    --Metrics.ExposePort=6060 \
    --Metrics.ExposeHost=0.0.0.0 \
    --Init.ChainSpecPath=/network-config/chainspec.json \
    --JsonRpc.EnabledModules=Eth,Subscribe,Trace,TxPool,Web3,Personal,Proof,Net,Parity,Health,Rpc,Debug,Admin \
    --Discovery.Bootnodes=${EXECUTION_BOOTNODES} \
    --Init.IsMining=false \
    --Pruning.Mode=None \
    --config=none \
    --log=INFO

