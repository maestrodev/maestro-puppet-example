shared_examples 'maestro agent' do |master = 'localhost'|
  USER_HOME="/var/local/maestro-agent"

  describe 'agent' do

    # not working with puppet rspec yet
    # it 'should honor hiera configuration' do
    #   should contain_package('maestro-agent').with_version('1.4.0')
    # end

    it { should contain_user('maestro_agent') }

    it { should contain_service('ntp').with_ensure('running') }
    it { should contain_package('java').with_name('java-1.6.0-openjdk-devel') }

    it 'should generate valid settings.xml' do
      expected = File.read(File.expand_path("basic_settings.xml", File.dirname(__FILE__)))
      expected.should_not be_nil

      content = catalogue.resource('file', "#{USER_HOME}/.m2/settings.xml").send(:parameters)[:content]
      content.should_not be_nil
      content.should eq(expected.gsub(/localhost/, master))
    end

    it 'should install the required packages for Selenium to run' do
      should contain_package('xorg-x11-server-Xvfb')
    end
  end
end
