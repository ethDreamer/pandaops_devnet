#!/bin/bash

PANDAOPS_REPO=fusaka-devnets

# Check if a TESTNET argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <TESTNET>"
    exit 1
fi

if [ ! -d "${PANDAOPS_REPO}/.git" ]; then
      echo "Missing ${PANDAOPS_REPO}. Run:  make init  (or)  git submodule update --init --remote"
        exit 1
fi

# Check if the directory exists
CONFIG_DIR="${PANDAOPS_REPO}/network-configs/$TESTNET"
if [ ! -d "$CONFIG_DIR" ]; then
    echo "Error: Directory '$CONFIG_DIR' does not exist."
    exit 1
fi
export TESTNET="$1"
export COMPOSE_PROJECT_NAME="$TESTNET"

PANDA_LIGHTHOUSE=$(cat ${PANDAOPS_REPO}/ansible/inventories/${TESTNET}/group_vars/all/images.yaml | yq .default_ethereum_client_images.lighthouse)
PANDA_NETHERMIND=$(cat ${PANDAOPS_REPO}/ansible/inventories/${TESTNET}/group_vars/all/images.yaml | yq .default_ethereum_client_images.nethermind)

export EXECUTION_NODE=nethermind
export LIGHTHOUSE_IMAGE=$PANDA_LIGHTHOUSE
export EXECUTION_IMAGE=$PANDA_NETHERMIND

export CONSENSUS_DISC=9000
export BEACON_HTTP=5052
export BEACON_METRICS=5054
export EXECUTION_DISC=30303
export RPC_PORT=8545
export EXECUTION_METRICS=6060

export CHECKPOINT_SYNC_URL=$(cat ${PANDAOPS_REPO}/kubernetes/${TESTNET}/homepage/values.yaml| yq .testnet-homepage.config.params.ethereum.checkpointSyncUrl)
export NETWORK_CONFIG=${PANDAOPS_REPO}/network-configs/${TESTNET}/metadata
export CONSENSUS_BOOTNODES=$(yq -r '.[] | .' ${PANDAOPS_REPO}/network-configs/${TESTNET}/metadata/bootstrap_nodes.yaml | awk 'BEGIN { srand() } { print rand(), $0 }' | sort -k1,1n | cut -d' ' -f2- | head -n 8 | tr '\n' ',' | sed 's/,$/\n/')
export EXECUTION_BOOTNODES=$(cat ${PANDAOPS_REPO}/network-configs/${TESTNET}/metadata/enodes.txt | awk 'BEGIN { srand() } { print rand(), $0 }' | sort -k1,1n | cut -d' ' -f2- | head -n 8 | tr '\n' ',' | sed 's/,$/\n/')


mkdir -p lighthouse/beacon/run/$TESTNET
mkdir -p ${EXECUTION_NODE}/run/$TESTNET


