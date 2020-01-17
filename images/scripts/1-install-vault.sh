#!/bin/sh

echo "Executing [$0]..."

# Stop script on any error
set -e

#################################################################
# Check if run as root
#################################################################
if [ ! $(id -u) -eq 0 ]; then
	echo "ERROR: Script [$0] must be run as root, Script terminating"
	exit 7
fi
#################################################################

# Define variables
SCRIPT_PATH=$(pwd)/Linux/common/REHL-CentOS
PORT=8200

cd /tmp

# Download the HashiCorp Vault (Enterprise)
wget -O /tmp/vault.zip "$VAULT_DOWNLOAD_URL"

# Unzip
unzip /tmp/vault.zip -d /tmp/vault

# Create vault user and group
groupadd vault
adduser -g vault -m vault

# Copy binary
mkdir -p /opt/vault
cp /tmp/vault/vault /bin

# Change ownership to vault
chown root:vault /bin/vault

####################################################################
# Check vault location
####################################################################
if [ ! $(command -v vault) ]; then
	echo "Vault not found.  Unable to continue"
	echo "Failure installing vault"
	exit 1
else
	echo "Vault Path: $(which vault)"
	echo "Successfully installed vault"
fi
####################################################################

## Configure Vault

# Create Vault config file
touch /opt/vault/vault.hcl
chmod 0640 /opt/vault/vault.hcl
# Leave the configuration to the cloud-init script

# Change ownership of Vault config and storage directory
chown -R vault:vault /opt/vault

# Create Vault systemd service file
cat <<'EOF' >/etc/systemd/system/vault.service
[Unit]
Description=HashiCorp Vault service
After=network-online.target
After=consul-online.target

[Service]
User=vault
PrivateDevices=yes
PrivateTmp=yes
ProtectSystem=full
ProtectHome=read-only
SecureBits=keep-caps
Capabilities=CAP_IPC_LOCK+ep
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
LimitMEMLOCK=infinity
ExecStart=/bin/vault server -config=/opt/vault/vault.hcl -dev -dev-root-token-id=root -dev-no-store-token
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT
TimeoutStopSec=30s
Restart=on-failure
RestartSec=15
StartLimitInterval=60s
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

chmod 0644 /etc/systemd/system/vault.service

cat <<EOF >/etc/profile.d/vault.sh
#!/bin/bash
export VAULT_ADDR='https://127.0.0.1:$PORT'
EOF

mkdir -p /var/log/vault
chmod 0700 /var/log/vault
touch /var/log/vault/vault_audit.log
chmod 0600 /var/log/vault/vault_audit.log
chown -R vault.vault /var/log/vault

cat <<EOF >/etc/logrotate.d/vault
/var/log/vault/vault_audit.log
{
    missingok
    rotate 7
    daily
    copytruncate
    dateext
    compress
}
EOF

# Configure Vault Server
echo Configuring Systemd Startup...
systemctl daemon-reload
#systemctl start vault
systemctl enable vault
# Configure selinux
setsebool -P user_tcp_server 1
echo Done!

echo "Executing [$0] complete"
