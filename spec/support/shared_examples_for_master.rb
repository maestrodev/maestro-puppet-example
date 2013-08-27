shared_examples 'maestro master' do |hostname = 'myhostname.acme.com'|

  describe 'master' do

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
    it { should contain_service('postgresqld').with_ensure('running') }
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

      content = catalogue.resource('file', '/var/lib/jenkins/.m2/settings.xml').send(:parameters)[:content]
      content.should eq(expected)
    end

    it { should contain_class('jenkins').with_jenkins_prefix('/jenkins') }

    it 'should download packages from maestrodev repo' do
      should contain_wget__authfetch('archiva_download').with(
        :user => 'your_username',
        :password => /.+/,
        :source => /https:\/\/repo.maestrodev.com\/archiva\/repository\/all/
      )
    end

    it 'should have the right postgres password' do
      should contain_class('maestro::maestro').with_db_server_password('maestro')
    end

    it 'should have the right version' do
      should contain_wget__authfetch('fetch-maestro-rpm').with_source(/-4..*\.rpm$/)
    end

    it 'should generate valid nginx proxy configurations' do
      content = catalogue.resource('file', "/etc/nginx/conf.d/maestro_app-upstream.conf").send(:parameters)[:content]
      content.should_not be_nil
      content.should =~ %r[localhost:8080]

      content = catalogue.resource('file', "/etc/nginx/conf.d/jenkins_app-upstream.conf").send(:parameters)[:content]
      content.should_not be_nil
      content.should =~ %r[localhost:8181]

      content = catalogue.resource('file', "/etc/nginx/conf.d/archiva_app-upstream.conf").send(:parameters)[:content]
      content.should_not be_nil
      content.should =~ %r[localhost:8082]
    end

    it 'should establish an nginx proxy' do
      should contain_class('maestro_nodes::nginxproxy').with(
                 :hostname => hostname,
                 :maestro_port => '8080',
                 :ssl => false,
             )
    end

    it { should contain_class('maestro_nodes::maestroserver').with_repo(repo) }
  end
end
