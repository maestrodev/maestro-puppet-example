require 'bundler'
Bundler.require(:rake)

require 'puppetlabs_spec_helper/rake_tasks'
require 'rake/clean'

CLEAN.include('modules', 'doc', 'spec/fixtures/manifests', 'spec/fixtures/modules', 'auth.conf',
  'fileserver.conf', 'hieradata/common.yaml', 'manifests/nodes/maestro.acme.com.pp', 'puppet.conf')
CLOBBER.include('.tmp', '.librarian')

task :librarian do
  sh "librarian-puppet install#{" --verbose" if verbose == true}"
end

task :default => [:clean, :librarian, :spec]
