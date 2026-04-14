#!/usr/bin/env bash
set -euo pipefail
set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# load config
source "$SCRIPT_DIR/config/defaults.sh"

echo "==> Creating VM"
bash "$SCRIPT_DIR/scripts/create-vm.sh"


PUBLIC_IP="$(get_public_ip)"
export PUBLIC_IP


SSH_HOST="$ADMIN_USER@$PUBLIC_IP"

SSH_OPTS="-o StrictHostKeyChecking=no \
          -o UserKnownHostsFile=/dev/null \
          -o BatchMode=yes"

SSH_MASTER_OPTS="$SSH_OPTS \
  -o ControlMaster=auto \
  -o ControlPersist=10m \
  -o ControlPath=/tmp/ssh-%r@%h:%p"

export SSH_OPTS SSH_HOST


echo "==> Opening SSH master connection"
ssh $SSH_MASTER_OPTS -i "$SSH_PRIV" -Nf "$SSH_HOST"


echo "==> Hardening SSH"
bash "$SCRIPT_DIR/scripts/harden-ssh.sh"

echo "==> Bootstrapping nginx"
bash "$SCRIPT_DIR/scripts/bootstrap-nginx.sh"


echo "==> Closing SSH master connection"
ssh -O exit $SSH_OPTS -i "$SSH_PRIV" "$SSH_HOST" 2>/dev/null || true


echo "✅ Deployment finished"

