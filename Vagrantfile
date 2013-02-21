Vagrant::Config.run do |config|

  config.vm.box = "CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://repo.maestrodev.com/archiva/repository/public-releases/com/maestrodev/vagrant/CentOS/6.3/CentOS-6.3-x86_64-minimal.box"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.forward_port 8080, 8080
  config.vm.forward_port 8082, 8082
  config.vm.forward_port 8181, 8181

  config.vm.host_name = "maestro.acme.com"

  vm_name = "Maestro example"
  config.vm.customize ["modifyvm", :id, "--memory", 4096]
  config.vm.customize ["modifyvm", :id, "--name", vm_name] # in order to export it with that name
  config.vm.customize ["modifyvm", :id, "--rtcuseutc", "on"] # use UTC clock https://github.com/mitchellh/vagrant/issues/912

  # use local git repo
  config.vm.share_folder "puppet", "/etc/puppet", ".", :create => true, :owner => "puppet", :group => "puppet"

  # Keep downloaded packages in host for faster creation of new vms
  if ENV["MAESTRO_CACHE"]
    src = File.expand_path("~/.maestro/src")
    File.exists?(File.expand_path(src)) or Dir.mkdir(src)
    config.vm.share_folder "src", "/usr/local/src", File.expand_path(src), :owner => "root", :group => "root"
    config.vm.share_folder "repo1", "/var/local/maestro-agent/.m2/repository", File.expand_path("~/.m2/repository")
    config.vm.share_folder "repo2", "/var/lib/jenkins/.m2/repository", File.expand_path("~/.m2/repository")
  end

  abort "MAESTRODEV_USERNAME must be set" unless ENV['MAESTRODEV_USERNAME']
  abort "MAESTRODEV_PASSWORD must be set" unless ENV['MAESTRODEV_PASSWORD']

  commit = `git rev-parse HEAD`
  puts "Provisioning using commit #{commit}"
  config.vm.provision :shell do |shell|
    shell.path = "get-maestro.sh"
    shell.args = "#{ENV['MAESTRODEV_USERNAME']} #{ENV['MAESTRODEV_PASSWORD']} #{commit}"
  end

  if ENV["MAESTRO_CACHE"]
    # remount the shared folders as the right user so compositions don't fail
    config.vm.provision :shell, :path => "remount.sh", :args => "repo1 /var/local/maestro-agent/.m2/repository maestro_agent"
    config.vm.provision :shell, :path => "remount.sh", :args => "repo2 /var/lib/jenkins/.m2/repository jenkins"
  end
end
