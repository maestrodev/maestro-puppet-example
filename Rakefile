require 'bundler'
Bundler.require(:rake)
require 'rake/clean'

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'

CLEAN.include('modules', 'doc', 'spec/fixtures/manifests', 'spec/fixtures/modules', 'auth.conf',
  'fileserver.conf', 'hieradata/common.yaml', 'manifests/nodes/maestro.acme.com.pp', 'puppet.conf', 'pkg')
CLOBBER.include('.tmp', '.librarian')

task :librarian do
  sh "librarian-puppet install#{" --verbose" if verbose == true}"
end

task :default => [:clean, :librarian, :spec]

# puppet module build includes too many files and no way to exclude them, so we overwrite the tarball manually
task :build do
  version = Blacksmith::Modulefile.new.version
  sh "cd pkg/maestrodev-maestro-puppet-example-#{version} && tar -czf ../maestrodev-maestro-puppet-example-#{version}.tar.gz Modulefile Puppetfile* manifests"
end
