services = ['vault']

# tests run by packer

include_controls 'packer-common' do
  skip_control 'telegraf_conf'
end

control 'group_and_user' do
  describe group('vault') do
    it { should exist }
  end
  describe user('vault') do
    it { should exist }
    its('group') { should eq 'vault' }
  end
end

control 'services' do
  services.each do |service|
    describe systemd_service("#{service}") do
      it { should be_installed }
      it { should be_enabled }
    end
  end
end

control 'vault_unit_file' do
  describe file('/etc/systemd/system/vault.service') do
      # its('owner') { should eq 'root' }
      its('mode') { should cmp '0644' }
  end
end

control 'vault_binary' do
  describe file('/usr/bin/vault') do
      # its('owner') { should eq 'root' }
      # its('group') { should eq 'vault' }
      its('mode') { should cmp '0755' }
  end
end

control 'vault_config' do
  describe directory('/opt/vault') do
    # its('owner') { should eq 'vault' }
    # its('group') { should eq 'vault' }
    its('mode') { should cmp '0755' }
  end
  describe file('/opt/vault/vault.hcl') do
    # its('owner') { should eq 'vault' }
    # its('group') { should eq 'vault' }
    its('mode') { should cmp '0640' }
  end
end

control 'env_vault' do
  describe file('/etc/profile.d/vault.sh') do
      # its('owner') { should eq 'root' }
      # its('group') { should eq 'root' }
      its('mode') { should cmp '0644' }
  end
end

control 'logging' do
  describe directory('/var/log/vault') do
    # its('owner') { should eq 'vault' }
    # its('group') { should eq 'vault' }
    its('mode') { should cmp '0700' }
  end
  describe file('/var/log/vault/vault_audit.log') do
    # its('owner') { should eq 'vault' }
    # its('group') { should eq 'vault' }
    its('mode') { should cmp '0600' }
  end
  describe file('/etc/logrotate.d/vault') do
    # its('owner') { should eq 'root' }
    # its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
  end
end
