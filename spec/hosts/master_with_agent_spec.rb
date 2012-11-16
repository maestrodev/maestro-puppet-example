require 'spec_helper'

describe 'master_with_agent' do
  let(:facts) { centos_facts }

  it_behaves_like 'maestro master'
  it_behaves_like 'maestro agent'
end
