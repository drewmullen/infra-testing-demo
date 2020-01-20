ip = input('ip', value: 'localhost')
# you add controls here
control "vault-health-check" do                        # A unique ID for this control
           # A human-readable title
  desc "verify vault health check"
  describe http("http://#{ip}:8200/v1/sys/health") do                  # The actual test 
    its('status') { should cmp 200 }
  end
end
