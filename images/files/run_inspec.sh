#!/usr/bin/env bash
/usr/bin/scl enable rh-ruby25 -- /opt/rh/rh-ruby25/root/usr/local/bin/inspec exec /opt/chef/inspec/common --reporter json --input-file /opt/chef/inspec/role.yml --chef-license=accept-silent | systemd-cat -t inspec
