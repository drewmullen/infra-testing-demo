role = input('role', value: 'consul')
shared_services = ['consul', 'td-agent-bit', 'puppet', 'telegraf']
vault_certs = ['/opt/vault/ssl/server.crt',
  '/opt/vault/ssl/ca.crt',
  '/opt/vault/ssl/server.key',
]
consul_certs = ['/opt/consul/ssl/server.crt',
  '/opt/consul/ssl/ca.crt',
  '/opt/consul/ssl/server.key',
]

# shared controls
control 'shared_service' do
  shared_services.each do |service|
    describe systemd_service("#{service}") do
      it { should be_installed }
      it { should be_enabled }
    end
  end
end

control 'consul_cert_files' do
  consul_certs.each do |cert|
    describe x509_certificate("#{cert}") do
      its('key_length') { should be >= 2048 }
    end
  end
end

# vault only controls
if ['vault'].include? role
  control 'vault_service' do
    describe systemd_service("vault") do
      it { should be_installed }
      it { should be_enabled }
    end
  end
  control 'vault_cert_files' do
    vault_certs.each do |cert|
      describe x509_certificate("#{cert}") do
        its('key_length') { should be >= 2048 }
      end
    end
  end
end

# consul only controls
if ['consul'].include? role
  control 'consul_backup_service' do
    describe systemd_service("consul-backup-agent") do
      it { should be_installed }
      it { should be_enabled }
    end
  end
end