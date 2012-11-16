Dir["./modules/maestro_nodes/spec/support/**/*.rb"].each {|f| require f}
Dir["./spec/support/**/*.rb"].each {|f| require f}
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.manifest_dir = './manifests'
  c.module_path = './modules'
end

Puppet::Util::Log.level = :warning
Puppet::Util::Log.newdestination(:console)

# Using Puppet 3 configure hiera
if Integer(Puppet.version.split('.').first) >= 3
  hiera_config = File.expand_path(File.join(__FILE__, '..', 'fixtures', 'hiera.yaml'))
  raise "Hiera config file does not exist: #{hiera_config}" unless File.exists? hiera_config
  Puppet[:hiera_config] = hiera_config
end
