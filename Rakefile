require 'bundler'
Bundler.require(:rake)
require 'puppetlabs_spec_helper/rake_tasks'
require 'rake/clean'
require 'maestro/plugin/rake_tasks/pom'
require 'puppet'

CLEAN.include('modules', 'doc', 'spec/fixtures/manifests', 'spec/fixtures/modules', 'auth.conf',
  'fileserver.conf', 'hieradata/common.yaml', 'manifests/nodes/maestro.acme.com.pp', 'puppet.conf', 'target')
CLOBBER.include('.tmp', '.librarian')

task :librarian do
  sh "librarian-puppet install#{" --verbose" if verbose == true}"
end
task :spec_prep => :librarian

task :package do
  files = "hiera.yaml manifests/*.pp manifests/nodes/default modules hieradata get-*.sh"
  pom = Maestro::Plugin::RakeTasks::Pom.new

  ["get-maestro.sh", "get-agent.sh"].each do |f|
    script = File.read(f)
    File.open(f, "w") do |file|
      file.puts(script.
        gsub(/^PUPPET_VERSION=.*$/, "PUPPET_VERSION=#{Puppet.version}").
        gsub(/^FACTER_VERSION=.*$/, "FACTER_VERSION=#{Facter.version}"))
    end
  end

  # clean up specs in modules before packaging
  Dir.glob('modules/*/spec/fixtures').each { |d| FileUtils.rm_rf(d) }

  FileUtils.mkdir_p 'target'
  version = pom[:version].chomp.split('-')
  iteration = "--iteration #{Time.now.getutc.strftime("%Y%m%d%H%M%S")}"
  sh "tar -czf target/#{pom[:artifactId]}-#{pom[:version]}.tar.gz #{files}"
  sh 'rpmbuild --version' do |ok, res|
    fpm = <<-EOS
      fpm -v #{version[0]} #{iteration} -n #{pom[:artifactId]} -s dir -t rpm -p target/#{pom[:artifactId]}-#{pom[:version]}.rpm \
      -a all --prefix /etc/puppet --description '#{pom[:description]}' --url '#{pom[:url]}' \
      --vendor 'MaestroDev, Inc.' #{files}
    EOS
    sh fpm if ok
  end
end

task :install => [:clean, :spec, :package] do
  sh "mvn install"
end

task :deploy => [:clean, :spec, :package] do
  sh "mvn deploy"
end

task :default => [:clean, :spec, :package]
