shared_examples 'maestro agent' do |master = 'localhost'|
  let(:user_home) { "/var/local/maestro-agent" }
  let(:agent_maxmem) { "128" }

  it 'should honor hiera configuration' do
    should contain_class('maestro::agent').with_agent_version('present')
  end

  it { should contain_user('maestro_agent') }

  it { should contain_service('ntp').with_ensure('running') }
  it { should contain_package('java').with_name('java-1.6.0-openjdk-devel') }

  it 'should generate valid settings.xml' do
    expected = File.read(File.expand_path("basic_settings.xml", File.dirname(__FILE__)))
    expected.should_not be_nil
    should contain_file("#{user_home}/.m2/settings.xml").with_content(expected.gsub(/localhost/, master))
  end

  it "modify wrapper.conf correctly" do
    augeas_resource_name = "maestro-agent-wrapper-maxmemory"
    should contain_augeas(augeas_resource_name)

    should contain_augeas(augeas_resource_name).with(
      'changes' => "set wrapper.java.maxmemory #{agent_maxmem}",
      'incl' => "/var/local/maestro-agent/conf/wrapper.conf")
  end

  it { should contain_class('maestro_nodes::agent').with_repo(repo) }

end
