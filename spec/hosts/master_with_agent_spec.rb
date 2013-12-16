require 'spec_helper'

describe 'master_with_agent' do
  let(:facts) { centos_facts.merge({
    :hostname => 'myhostname',
    :fqdn => 'myhostname.acme.com',
    :maestro_node_type => 'master_with_agent',
    :maestro_host => 'localhost'
  }) }

  include_context :maestro
  it_behaves_like 'maestro master'
  it_behaves_like 'maestro agent'

  it { should contain_class('maestro::agent').with_agent_name('myhostname') }

  it { should_not contain_class('sonar') }
end
