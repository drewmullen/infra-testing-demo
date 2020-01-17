#!/bin/bash

set -e

# default Telegraf version should be overridable in the Packer config
TELEGRAF_VERSION="${TELEGRAF_VERSION:-1.10.3-1}"
TELEGRAF_URL="https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}.x86_64.rpm"
LOCAL_TMP=$(mktemp -d)

# install and disable, since it should only be enabled in user data
curl -Lo ${LOCAL_TMP}/telegraf.rpm ${TELEGRAF_URL}
yum -y localinstall ${LOCAL_TMP}/telegraf.rpm
systemctl disable telegraf

# clean up
rm -rf ${LOCAL_TMP}

# disable service and remove default configuration
rm /etc/telegraf/telegraf.conf

# insert new default configuration
# additional configuration will be added through user data
# config file directory is /etc/telegraf/telgraf.conf.d/
cat <<EOF > /etc/telegraf/telegraf.conf
[agent]
  interval = "60s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"
  precision = ""
  debug = false
  quiet = false
  logfile = ""
  hostname = ""
  omit_hostname = false

EOF