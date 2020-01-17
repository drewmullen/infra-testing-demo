# copyright: 2018, The Authors

title "Sample Section"
azurerm_resource_groups = ["drew-rsg"]

# control 'azure_network_security_group' do
#   azurerm_resource_groups.names.each do |resource_group_name|                  # Plural resources can be leveraged to loop across many resources
    describe azurerm_network_security_group(resource_group: "drew-rsg", name: 'vault-nsg') do
      it                            { should exist }
      # its('type')                   { should eq 'Microsoft.Network/networkSecurityGroups' }
      its('security_rules')         { should_not be_empty }
      # its('default_security_rules') { should_not be_empty }
      # it                            { should_not allow_rdp_from_internet }
      # it                            { should_not allow_ssh_from_internet }
      end
#   end
# end
