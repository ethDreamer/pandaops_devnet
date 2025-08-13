#!/bin/bash


lighthouse beacon_node \
    --datadir=/data/$TESTNET \
    --testnet-dir=/network-config \
    --checkpoint-sync-url=${CHECKPOINT_SYNC_URL} \
    --disable-upnp \
    --subscribe-all-data-column-subnets \
    --enr-tcp-port=${CONSENSUS_DISC} \
    --enr-udp-port=${CONSENSUS_DISC} \
    --listen-address=0.0.0.0 \
    --port=${CONSENSUS_DISC} \
    --discovery-port=${CONSENSUS_DISC} \
    --http \
    --http-address=0.0.0.0 \
    --http-port=5052 \
    --execution-endpoint=http://execution:8551 \
    --metrics \
    --metrics-address=0.0.0.0 \
    --metrics-allow-origin=* \
    --metrics-port=5054 \
    --execution-jwt=/execution-auth.jwt \
    --boot-nodes=$CONSENSUS_BOOTNODES


#sleep infinity
