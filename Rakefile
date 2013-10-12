require 'bundler'
# Bundler.require(:rake)
require 'rake/clean'
require 'maestro/plugin/rake_tasks/pom'


CLEAN.include('modules', 'doc', 'spec/fixtures/manifests', 'spec/fixtures/modules', 'auth.conf',
  'fileserver.conf', 'hieradata/common.yaml', 'manifests/nodes/maestro.acme.com.pp', 'puppet.conf', 'target')
CLOBBER.include('.tmp', '.librarian')

task :librarian do
  sh "librarian-puppet install#{" --verbose" if verbose == true}"
end

task :package do
  files = "hiera.yaml manifests/*.pp manifests/nodes/default modules hieradata"
  pom = Maestro::Plugin::RakeTasks::Pom.new

  # clean up specs in modules before packaging
  Dir.glob('modules/*/spec/fixtures').each { |d| FileUtils.rm_rf(d) }

  FileUtils.mkdir_p 'target'
  version = pom[:version].chomp.split('-')
  iteration = version.length > 1 ? "--iteration #{version[1]}" : ''
  sh "tar -czf target/#{pom[:artifactId]}-#{pom[:version]}.tar.gz #{files}"
  sh 'rpmbuild --version' do |ok, res|
    fpm = <<-EOS
      fpm -v #{version[0]} #{iteration} -n #{pom[:artifactId]} -s dir -t rpm -p target/#{pom[:artifactId]}-#{pom[:version]}.rpm \
      -a all --prefix /etc/puppet --description '#{pom[:description]}' --url '#{pom[:url]}' \
      --vendor 'MaestroDev, Inc.' -d puppet-server #{files}
    EOS
    sh fpm if ok
  end
end

task :install => [:clean, :librarian, :spec, :package] do
  sh "mvn install"
end

task :deploy => [:clean, :librarian, :spec, :package] do
  sh "mvn deploy"
end

task :default => [:clean, :librarian, :spec, :package]