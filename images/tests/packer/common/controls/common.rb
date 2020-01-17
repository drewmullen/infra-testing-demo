# tests run by packer
pkgs = [
  'epel-release',
  'unzip',
  'jq',
  'td-agent-bit',
  'telegraf',
  'azure-cli',
  'rh-ruby25',
  'rh-ruby25-ruby-devel',
  'gcc',
  'gcc-c++',
  'glibc-devel',
  'make',
  'libffi',
  'libffi-devel'
]

control 'packages' do
  pkgs.each do |pkg|
    describe package("#{pkg}") do
      it { should be_installed }
    end
  end
end

# gem_pkgs = [
#   'inspec-bin',
#   'ed25519',
#   'bcrypt_pbkdf'
# ]

# cant check: ed25519 bcrypt_pbkdf

# Error: Illformed requirement ["/opt/rh/rh-ruby25/root/usr/bin/gem"]
# control 'gem_packages' do
#   gem_pkgs.each do |gem|
#     describe gem("#{gem}", "/opt/rh/rh-ruby25/root/usr/bin/gem") do
#       it { should be_installed }
#     end
#   end
# end
#/opt/rh/rh-ruby25/root/usr/local/share/gems/gems/ed25519-1.2.4/ext/ed25519_jruby/net/i2p/crypto/eddsa/math/ed25519

control 'inspec_gem_package' do
  describe file('/opt/rh/rh-ruby25/root/usr/local/bin/inspec') do
    it { should exist }
  end
end


control 'td_agent_conf_file' do
  describe file('/etc/td-agent-bit/td-agent-bit.conf') do
    it { should exist }
    its('mode') { should cmp '0644' }
  end
end

control 'telegraf_conf' do
  describe file('/etc/telegraf/telegraf.conf') do
    its('md5sum') { should eq 'eedf6f6ebe501cc125a6277be16e53ff' }
    its('mode') { should cmp '0644' }
  end
end

# CONFIRM CHANGE TO WAAGENT