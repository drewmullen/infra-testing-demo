# End to End Testing Immutable Infrastructure in Azure

## Building a local development environment

Create your variables-local.json

```json
{
    "client_secret": "",
    "client_id": "",
    "dest_subscription_id": "",
    "tenant_id": "",
    "build_resource_group_name": "drew-rsg",
    "managed_image_resource_group_name": "drew-rsg",
    "git_ref": "personal",
    "vault_download_url": "https://releases.hashicorp.com/vault/1.3.0/vault_1.3.0_linux_amd64.zip",
    "consul_download_url": "https://releases.hashicorp.com/consul/1.6.2/consul_1.6.2_linux_amd64.zip",
    "consul_version_number": "1.6.2",
    "vault_version_number": "1.3.0",
    "sig_version": "0.0.1",
    "sig_replication_regions": "East US"
}
```

Build local image

```bash
cd images/
packer build -only=vagrant -var-file=variables-local.json build-vault.json
```

Add 'box' to local Vagrant registry

```bash
vagrant box add --name vagrantvault --provider virtualbox output-vagrant/package.box
cd ../ && mkdir dev-vagrant && cd dev-vagrant
vagrant init -m vagrantvault
vagrant up
```

Execute tests against local dev VM

```bash
inspec init profile myprofile
inspec exec myprofile -t ssh://vagrant@127.0.0.1:2222 -i .vagrant/machines/default/virtualbox/private_key

# use provided tests
inspec exec ../images/tests/packer/vault -t ssh://vagrant@127.0.0.1:2222 -i .vagrant/machines/default/virtualbox/private_key
```