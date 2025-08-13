# Ethereum Devnet Docker Stack

This repository provides a Docker Compose setup for running an Ethereum devnet environment with the following services:

- **Beacon Node** ([Lighthouse](https://github.com/sigp/lighthouse))
- **Execution Node** ([Nethermind](https://github.com/NethermindEth/nethermind))
- **Prometheus** for metrics scraping
- **Grafana** for metrics visualization

---

## 📦 Prerequisites

- **Docker** and **Docker Compose** installed
- **Git** with submodule support
- [`yq`](https://github.com/mikefarah/yq) installed (for `source_me.sh`)

---

## 🚀 Setup

1. **Clone this repo** and initialize the `fusaka-devnets` submodule:
   ```bash
   git clone git@github.com:ethDreamer/pandaops_devnet.git
   cd pandaops_devnet
   git submodule update --init --remote
   ```

2. **Source the environment** for your chosen testnet:
   ```bash
   source source_me.sh <TESTNET>
   ```
   This:
   - Sets environment variables for Docker Compose
   - Sets `COMPOSE_PROJECT_NAME` so containers are prefixed with the testnet name
   - Creates persistent run directories

3. **Start the stack**:
   ```bash
   docker compose up -d
   ```

---

## 📊 Metrics & Monitoring

- **Prometheus**: [http://localhost:9090](http://localhost:9090)
- **Grafana**: [http://localhost:3000](http://localhost:3000) (default user/pass: `admin` / `admin`)
- **Beacon metrics**: Exposed internally on `beacon:5054`
- **Nethermind metrics**: Exposed internally on `execution:6060`

Prometheus config (`prometheus/prometheus.yml`) scrapes both Lighthouse and Nethermind.

---

## 🧹 Clearing Data

To reset Prometheus, Grafana, and client data without deleting important scripts/configs:
```bash
./clean.sh
```

---


## ⚠️ Disclaimer

This stack is intended for **development/devnet purposes only** and is not hardened for mainnet or production use.

