require 'spec_helper'

describe 'agent' do
  let(:facts) { centos_facts.merge({
    :hostname => 'agent-01',
    :fqdn => 'agent-01.maestrodev.net',
    :maestro_node_type => 'agent',
    :maestro_host => 'maestro.maestrodev.net'
  }) }
  
  it_behaves_like 'maestro agent', 'maestro.maestrodev.net'
  
  it do should contain_class('maestro::agent').with(
    'agent_name' => 'agent-01',
    'stomp_host' => 'maestro.maestrodev.net')
  end
  
  it { should_not contain_service('maestro') }
  it { should_not contain_service('activemq') }
  it { should_not contain_service('jenkins') }
  it { should_not contain_service('maestro-test-remote-control') }
  it { should_not contain_service('postgresqld') }
  it { should_not contain_service('maestro-test-hub') }
  it { should_not contain_service('continuum') }
  it { should_not contain_service('sonar') }
  it { should_not contain_service('archiva') }
end
