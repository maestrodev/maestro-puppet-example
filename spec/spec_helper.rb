Dir["./modules/maestro_nodes/spec/support/**/*.rb"].each {|f| require f}
Dir["./spec/support/**/*.rb"].each {|f| require f}
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.manifest_dir = './manifests'
  c.module_path = './modules'
  c.default_facts = MaestroNodes::CentOS.centos_facts

  hiera_config = File.expand_path(File.join(__FILE__, '..', 'fixtures', 'hiera.yaml'))
  raise "Hiera config file does not exist: #{hiera_config}" unless File.exists? hiera_config
  c.hiera_config = hiera_config
  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.before(:each) do
    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)

    # work around https://tickets.puppetlabs.com/browse/PUP-1547
    # ensure that there's at least one provider available by emulating that any command exists
    require 'puppet/confine/exists'
    Puppet::Confine::Exists.any_instance.stubs(:which => '')
    # avoid "Only root can execute commands as other users"
    Puppet.features.stubs(:root? => true)
  end
end

shared_examples :compile, :compile => true do
  it { should compile.with_all_deps }
end
