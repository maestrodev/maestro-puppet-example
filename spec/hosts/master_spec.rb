require 'spec_helper'

describe 'master' do
  let(:facts) { centos_facts.merge({:fqdn => 'myhostname.acme.com'}) }

  it_behaves_like 'maestro master'

  it { should_not contain_class('svn') }
  it { should_not contain_class('sonar') }
end
