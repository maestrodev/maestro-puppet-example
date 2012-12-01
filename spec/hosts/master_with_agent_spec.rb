require 'spec_helper'

describe 'master_with_agent' do
  let(:facts) { centos_facts.merge({:hostname => 'myhostname'}) }

  it { should contain_class('maestro::agent').with_agent_name('myhostname') }

  it_behaves_like 'maestro master'
  it_behaves_like 'maestro agent'
end
