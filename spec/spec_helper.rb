Dir["./modules/maestro_nodes/spec/support/**/*.rb"].each {|f| require f}
Dir["./spec/support/**/*.rb"].each {|f| require f}
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.include MaestroNodes::CentOS # set centos_facts as default facts
  c.manifest_dir = './manifests'
  c.module_path = './modules'

  c.before(:all) do
    hiera_config = File.expand_path(File.join(__FILE__, '..', 'fixtures', 'hiera.yaml'))
    raise "Hiera config file does not exist: #{hiera_config}" unless File.exists? hiera_config
    Puppet[:hiera_config] = hiera_config
  end
  c.before(:each) do
    Puppet::Util::Log.level = :warning
    Puppet::Util::Log.newdestination(:console)
  end
end
