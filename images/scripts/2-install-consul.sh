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
SERVER_PORT=8300
SERF_PORT_LAN=8301 # TCP and UDP
SERF_PORT_WAN=8302 # TCP and UDP
HTTP_PORT=8500
DNS_PORT=8600

cd /tmp

# Downloading Consul OS for now:
wget -O /tmp/consul.zip "$CONSUL_DOWNLOAD_URL"

# Unzip
unzip /tmp/consul.zip -d /tmp/consul

# Create consul user and group
groupadd consul
adduser -g consul -m consul

# Copy binary
mkdir -p /opt/consul
mkdir -p /data/consul
cp /tmp/consul/consul /bin

# Change ownership to consul
chown root:consul /bin/consul

####################################################################
# Check consul location
####################################################################
if [ ! $(command -v consul) ]; then
	echo "Consul not found.  Unable to continue"
	echo "Failure installing consul"
	exit 1
else
	echo "Consul Path: $(which consul)"
	echo "Successfully installed consul"
fi
####################################################################

## Configure Consul

# Create Consul config file
# Barebones config options - the rest should be added as user-data
cat <<EOF >/opt/consul/consul.hcl
data_dir = "/data/consul"
performance {
    raft_multiplier = 1
}
EOF
chmod 0640 /opt/consul/consul.hcl

# Change ownership of Consul config
chown -R consul:consul /opt/consul
chown -R consul:consul /data/consul

# Create Consul systemd service file
cat <<EOF >/usr/lib/systemd/system/consul.service
[Unit]
Description="HashiCorp Consul - A service mesh solution"
Documentation=https://www.consul.io/
Requires=network-online.target
After=network-online.target
ConditionFileNotEmpty=/opt/consul/consul.hcl

[Service]
User=consul
Group=consul
ExecStart=/bin/consul agent -config-dir=/opt/consul
ExecReload=/bin/consul reload
KillMode=process
Restart=on-failure
RestartSec=15
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Allow http and https ports through firewall
if [ $(systemctl -q is-active firewalld) ]; then
	echo Configuring Firewall...
	sudo firewall-cmd --permanent --zone=public --add-service=22/tcp
	sudo firewall-cmd --permanent --zone=public --add-port=$SERVER_PORT/tcp
	sudo firewall-cmd --permanent --zone=public --add-port=$SERF_PORT_LAN/tcp
	sudo firewall-cmd --permanent --zone=public --add-port=$SERF_PORT_LAN/udp
	sudo firewall-cmd --permanent --zone=public --add-port=$SERF_PORT_WAN/tcp
	sudo firewall-cmd --permanent --zone=public --add-port=$SERF_PORT_WAN/udp
	sudo firewall-cmd --permanent --zone=public --add-port=$HTTP_PORT/tcp
	sudo firewall-cmd --permanent --zone=public --add-port=$DNS_PORT/udp
	sudo firewall-cmd --reload
	echo Done!
fi

# Configure Consul Server
echo Configuring Systemd Startup...
systemctl daemon-reload
# We don't actually want consul to start
#systemctl start consul
systemctl enable consul

# Ensure no hardcoded node-ids exist:
rm -f /data/consul/node-id
# Configure selinux
#sed -i 's/^SELINUX=.*$/SELINUX=permissive/' /etc/selinux/config
setsebool -P httpd_can_network_connect 1
setsebool -P user_tcp_server 1
echo Done!

echo "Executing [$0] complete"
