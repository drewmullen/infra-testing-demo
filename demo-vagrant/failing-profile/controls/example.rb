# copyright: 2018, The Authors

title "sample section"

# you can also use plain tests
describe file("/tmp/dir_doesnt_exist") do
  it { should be_directory }
end

# you add controls here
control "tmp-1.0" do                        # A unique ID for this control
  impact 0.7                                # The criticality, if this control fails.
  title "Create /tmp/dir_doesnt_exist directory"             # A human-readable title
  desc "An optional description..."
  describe file("/tmp/dir_doesnt_exist") do                  # The actual test
    it { should be_directory }
  end
end
