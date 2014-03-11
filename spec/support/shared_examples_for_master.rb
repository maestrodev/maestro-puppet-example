shared_examples 'maestro master' do |hostname = 'myhostname.acme.com'|

  it 'should honor hiera configuration' do
    should contain_class('maestro::maestro').with_version(maestro_version)
  end

  it { should contain_user('maestro') }
  it { should contain_group('maestro') }
#  it { should contain_user('jenkins') }
  it { should_not contain_file('/root/.mavenrc') }

  it { should contain_class('maestro') }
  it { should contain_package('java').with_name('java-1.6.0-openjdk-devel') }
  it { should contain_class('activemq').with_max_memory('64') }

  it { should contain_service('maestro').with_ensure('running') }
  it { should contain_service('activemq').with_ensure('running') }
  it { should contain_service('jenkins').with_ensure('running') }
  it { should_not contain_service('maestro-test-remote-control') }
  it { should contain_service('postgresqld').with_ensure(/running|true/) }
  it { should contain_service('ntp').with_ensure('running') }
  it { should_not contain_service('maestro-test-hub') }
  it { should_not contain_service('continuum') }
  it { should contain_service('archiva').with_ensure('running') }

  it { should contain_class('maestro::maestro').with_jetty_forwarded(true) }

  it "should add the metrics repo" do
    should contain_class('maestro::maestro').with_metrics_enabled(true)
    should contain_class('statsd')
    should contain_class('mongodb')
  end

  it 'should run archiva under archiva user' do
    should contain_file('basic/archiva.xml').with(
      'owner' => 'archiva',
      'group' => 'archiva'
  ) end

  it 'should run archiva under archiva user' do
    should contain_class('archiva').with(
      'user' => 'archiva',
      'group' => 'archiva'
  ) end

  it 'should generate valid settings.xml' do
    file = File.open(File.expand_path("basic_settings.xml", File.dirname(__FILE__)), "r")
    expected = file.read

    should contain_file('/var/lib/jenkins/.m2/settings.xml').with_content(expected)
  end

  it { should contain_class('jenkins') }

  it 'should download packages from maestrodev repo' do
    should contain_wget__authfetch('archiva_download').with(
      :user => 'your_username',
      :password => /.+/,
      :source => /https:\/\/repo.maestrodev.com\/archiva\/repository\/all/
    )
  end

  it 'should have the right postgres password' do
    should contain_class('maestro::maestro::db').with_password('maestro')
  end

  it 'should have the right version' do
    should contain_wget__authfetch('fetch-maestro-rpm').with_source(/-5..*\.rpm$/)
  end

  context 'when generating valid nginx proxy configurations' do
    it { should contain_file("/etc/nginx/conf.d/maestro_app-upstream.conf").with_content(%r[localhost:8080]) }
    it { should contain_file("/etc/nginx/conf.d/jenkins_app-upstream.conf").with_content(%r[localhost:8181]) }
    it { should contain_file("/etc/nginx/conf.d/archiva_app-upstream.conf").with_content(%r[localhost:8082]) }
  end

  it 'should establish an nginx proxy' do
    should contain_class('maestro_nodes::nginxproxy').with(
               :hostname => hostname,
               :maestro_port => '8080',
               :ssl => false,
           )
  end

  it { should contain_class('maestro_nodes::maestroserver').with_repo(repo) }

  it { should contain_class('maestro::lucee').with_is_demo(true) }

end
