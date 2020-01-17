
# log script execution to systemd journal
LOG_ID="azure"
TMP_LOG=$(mktemp)
exec > $${TMP_LOG} 2>&1

private_ip=$(hostname -I  | cut -d " " -f1)
echo $${private_ip}

mkdir -m777 -p /tmp/vault
chown -R vault:vault /tmp/vault

cat <<TD_AGENT_CONFIG > /etc/td-agent-bit/td-agent-bit.conf
[SERVICE]
  Log_Level error

[INPUT]
  Name  systemd
  Tag   host.*

[OUTPUT]
  Name        azure
  Match       *
  Customer_ID ${workspace_id}
  Shared_key  ${primary_shared_key}
TD_AGENT_CONFIG

systemctl enable td-agent-bit
systemctl start td-agent-bit

mkdir /etc/systemd/system/vault.service.d
cat <<EOF> /etc/systemd/system/vault.service.d/vault.conf
[Service]
ExecStart=
ExecStart=/bin/vault server -config=/opt/vault/vault.hcl -dev -dev-root-token-id=root -dev-no-store-token
EOF

cat <<VAULT_CONFIG >/opt/vault/vault.hcl
ui = true

listener "tcp" {
  address     = "$${private_ip}:8200"
  tls_disable = 1
}
VAULT_CONFIG

# Restart Vault to get the unseal changes
service vault restart

# log script execution to systemd journal
systemd-cat -t $${LOG_ID} < $${TMP_LOG}
rm $${TMP_LOG}
