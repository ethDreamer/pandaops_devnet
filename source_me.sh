#!/usr/bin/env bash
# Safe to source or execute. On error:
# - if sourced: returns non-zero
# - if executed: exits non-zero

PANDAOPS_REPO="fusaka-devnets"

is_sourced() { [[ "${BASH_SOURCE[0]}" != "$0" ]]; }

die() {
  echo "Error: $*" >&2
  if is_sourced; then return 1; else exit 1; fi
}

# ---- Args ----
if [[ $# -lt 1 ]]; then
  echo "Usage: ${BASH_SOURCE[0]} <TESTNET>"
  if is_sourced; then return 2; else exit 2; fi
fi
TESTNET="$1"

# ---- Pre-flight checks ----
# submodule present?
[[ -f "${PANDAOPS_REPO}/.git" ]] || die "Missing ${PANDAOPS_REPO}. Run:  make init  (or)  git submodule update --init --remote"

# config dir exists?
CONFIG_DIR="${PANDAOPS_REPO}/network-configs/${TESTNET}"
[[ -d "$CONFIG_DIR" ]] || die "Directory not found: ${CONFIG_DIR}"

# tool checks (optional but helpful)
command -v yq >/dev/null 2>&1 || die "yq is required but not found in PATH"

# ---- Exports ----
export TESTNET
export COMPOSE_PROJECT_NAME="$TESTNET"   # prefixes compose resources

# Allow env overrides; otherwise use these defaults
export CONSENSUS_DISC="${CONSENSUS_DISC:-9000}"
export BEACON_HTTP="${BEACON_HTTP:-5052}"
export BEACON_METRICS="${BEACON_METRICS:-5054}"
export EXECUTION_DISC="${EXECUTION_DISC:-30303}"
export RPC_PORT="${RPC_PORT:-8545}"
export EXECUTION_METRICS="${EXECUTION_METRICS:-6060}"

# Pull images from pandaops inventory unless overridden
DEFAULT_LIGHTHOUSE_IMAGE="$(yq .default_ethereum_client_images.lighthouse \
  < "${PANDAOPS_REPO}/ansible/inventories/${TESTNET}/group_vars/all/images.yaml")" \
  || die "Failed to read lighthouse image"

DEFAULT_NETHERMIND_IMAGE="$(yq .default_ethereum_client_images.nethermind \
  < "${PANDAOPS_REPO}/ansible/inventories/${TESTNET}/group_vars/all/images.yaml")" \
  || die "Failed to read nethermind image"

export EXECUTION_NODE="${EXECUTION_NODE:-nethermind}"
export LIGHTHOUSE_IMAGE="${LIGHTHOUSE_IMAGE:-$DEFAULT_LIGHTHOUSE_IMAGE}"
export EXECUTION_IMAGE="${EXECUTION_IMAGE:-$DEFAULT_NETHERMIND_IMAGE}"

# Derived config
export CHECKPOINT_SYNC_URL="$(
  yq .testnet-homepage.config.params.ethereum.checkpointSyncUrl \
  < "${PANDAOPS_REPO}/kubernetes/${TESTNET}/homepage/values.yaml"
)" || die "Failed to read checkpoint sync URL"

export NETWORK_CONFIG="${PANDAOPS_REPO}/network-configs/${TESTNET}/metadata"

# Randomize/limit bootnodes
export CONSENSUS_BOOTNODES="$(
  yq -r '.[] | .' "${NETWORK_CONFIG}/bootstrap_nodes.yaml" \
    | awk 'BEGIN { srand() } { print rand(), $0 }' \
    | sort -k1,1n \
    | cut -d" " -f2- \
    | head -n 8 \
    | tr "\n" "," \
    | sed 's/,$//'
)" || die "Failed to build CONSENSUS_BOOTNODES"

export EXECUTION_BOOTNODES="$(
  awk 'BEGIN { srand() } { print rand(), $0 }' "${NETWORK_CONFIG}/enodes.txt" \
    | sort -k1,1n \
    | cut -d" " -f2- \
    | head -n 8 \
    | tr "\n" "," \
    | sed 's/,$//'
)" || die "Failed to build EXECUTION_BOOTNODES"

# Ensure data dirs exist
mkdir -p "lighthouse/beacon/run/${TESTNET}" \
         "${EXECUTION_NODE}/run/${TESTNET}" || die "Failed to create data directories"

# If executed directly, just print a hint
if ! is_sourced; then
  echo "Environment prepared for TESTNET='${TESTNET}'. You can now run: docker compose up -d"
fi

