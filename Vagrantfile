Vagrant::Config.run do |config|

  config.vm.box = ENV["MAESTRO_CENTOS_BOX"] || "CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://repo.maestrodev.com/archiva/repository/public-releases/com/maestrodev/vagrant/CentOS/6.3/CentOS-6.3-x86_64-minimal.box"

  # Forward a port from the guest to the host, which allows for outside
  # computers to access the VM, whereas host only networking does not.
  config.vm.forward_port 8080, 8080
  config.vm.forward_port 8082, 8082
  config.vm.forward_port 8181, 8181
  config.vm.forward_port 61613, 61613
  config.vm.forward_port 5432, 5432

  config.vm.host_name = "maestro.acme.com"

  vm_name = "Maestro example"
  vm_memory = ENV["MAESTRO_VM_MEMORY"] || 4096
  config.vm.customize ["modifyvm", :id, "--memory", vm_memory]
  config.vm.customize ["modifyvm", :id, "--name", vm_name] # in order to export it with that name
  config.vm.customize ["modifyvm", :id, "--rtcuseutc", "on"] # use UTC clock https://github.com/mitchellh/vagrant/issues/912

  # use local git repo
  config.vm.share_folder "puppet", "/etc/puppet", ".", :create => true, :owner => "puppet", :group => "puppet"

  # Keep downloaded packages in host for faster creation of new vms
  if ENV["MAESTRO_CACHE"]
    src = File.expand_path("~/.maestro/src")
    File.exists?(File.expand_path(src)) or Dir.mkdir(src)
    config.vm.share_folder "src", "/usr/local/src", src, :owner => "root", :group => "root"
    config.vm.share_folder "repo1", "/var/local/maestro-agent/.m2/repository", File.expand_path("~/.m2/repository")
    config.vm.share_folder "repo2", "/var/lib/jenkins/.m2/repository", File.expand_path("~/.m2/repository")
    # keep yum cache in host
    config.vm.provision :shell, :inline => "sed -i 's/keepcache=0/keepcache=1/' /etc/yum.conf"
    yum = File.expand_path("~/.maestro/yum")
    File.exists?(File.expand_path(yum)) or Dir.mkdir(yum)
    config.vm.share_folder "yum", "/var/cache/yum", yum, :owner => "root", :group => "root"
  end

  abort "MAESTRODEV_USERNAME must be set" unless ENV['MAESTRODEV_USERNAME']
  abort "MAESTRODEV_PASSWORD must be set" unless ENV['MAESTRODEV_PASSWORD']

  commit = `git rev-parse HEAD`
  puts "Provisioning using commit #{commit} on branch #{ENV['BRANCH']}"

  config.vm.provision :shell do |shell|
    shell.path = "get-maestro.sh"
    shell.args = "#{ENV['MAESTRODEV_USERNAME']} #{ENV['MAESTRODEV_PASSWORD']} '#{ENV['NODE_TYPE']}' #{ENV['BRANCH']}"
  end

  if ENV["MAESTRO_CACHE"]
    # remount the shared folders as the right user so compositions don't fail
    config.vm.provision :shell, :path => "remount.sh", :args => "repo1 /var/local/maestro-agent/.m2/repository maestro_agent"
    config.vm.provision :shell, :path => "remount.sh", :args => "repo2 /var/lib/jenkins/.m2/repository jenkins"
  end
end
