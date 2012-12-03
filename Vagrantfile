# Vagrant box for the 'basic' downloadable vm

Vagrant::Config.run do |config|

  config.vm.box = "CentOS-6.3-x86_64-minimal"
  config.vm.box_url = "https://repo.maestrodev.com/archiva/repository/public-releases/com/maestrodev/vagrant/CentOS/6.3/CentOS-6.3-x86_64-bare.box"

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

  config.vm.provision :shell do |shell|
    shell.path = "get-maestro.sh"
    shell.args = "#{ENV['MAESTRODEV_USERNAME']} #{ENV['MAESTRODEV_PASSWORD']} development"
  end
end
