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

# Installing Ruby
yum install -y centos-release-scl
yum-config-manager --enable rhel-server-rhscl-7-rpms
yum install -y rh-ruby25 rh-ruby25-ruby-devel
source /opt/rh/rh-ruby25/enable
echo -e "#!/bin/bash\nsource scl_source enable rh-ruby25" > /etc/profile.d/scl_enable.sh
yum install -y gcc gcc-c++ glibc-devel make libffi libffi-devel 
ruby --version

# Installing inspect gem
gem install inspec-bin ed25519 bcrypt_pbkdf --no-rdoc --no-ri inspec-bin

echo Done!

echo "Executing [$0] complete"
