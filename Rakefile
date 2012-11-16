require 'bundler'
Bundler.require(:rake)

require 'puppetlabs_spec_helper/rake_tasks'
require 'rake/clean'

PuppetLint.configuration.send("disable_80chars")
CLEAN.include('modules', 'doc', 'spec/fixtures/manifests', 'spec/fixtures/modules')
CLOBBER.include('.tmp', '.librarian')

task :librarian do
  sh "librarian-puppet install#{" --verbose" if verbose == true}"
end

task :default => [:clean, :librarian, :spec]
