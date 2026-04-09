#!/usr/bin/env bash
set -euo pipefail
set -x


ssh $SSH_OPTS "$SSH_HOST" <<'EOF'

set -euo pipefail

###############################################################################
# SSH HARDENING
###############################################################################
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?UsePAM.*/UsePAM yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

grep -q "^AllowUsers" /etc/ssh/sshd_config || \
  echo "AllowUsers devopsadmin" | sudo tee -a /etc/ssh/sshd_config

sudo systemctl restart ssh

echo "✅ bootstrap SSH harden finished"
EOF
