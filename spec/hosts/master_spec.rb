require 'spec_helper'

describe 'master' do
  let(:facts) { centos_facts }

  it_behaves_like 'maestro master'

  it { should_not contain_class('svn') }
end
