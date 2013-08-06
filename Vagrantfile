# Common config for all vms
def setup(config)
  config.vm.customize ["modifyvm", :id, "--rtcuseutc", "on"] # use UTC clock https://github.com/mitchellh/vagrant/issues/912

  # Keep downloaded packages in host for faster creation of new vms
  if ENV["MAESTRO_CACHE"]
    src = File.expand_path("~/.maestro/src")
    File.exists?(File.expand_path(src)) or Dir.mkdir(src)
    config.vm.share_folder "src", "/usr/local/src", src, :owner => "root", :group => "root"
    config.vm.share_folder "repo1", "/var/local/maestro-agent/.m2/repository", File.expand_path("~/.m2/repository"), :create => true, :extra => "dmode=777,fmode=666"
    config.vm.share_folder "repo2", "/var/lib/jenkins/.m2/repository", File.expand_path("~/.m2/repository"), :create => true, :extra => "dmode=777,fmode=666"
    # keep yum cache in host
    config.vm.provision :shell, :inline => "sed -i 's/keepcache=0/keepcache=1/' /etc/yum.conf"
    yum = File.expand_path("~/.maestro/yum")
    File.exists?(File.expand_path(yum)) or Dir.mkdir(yum)
    config.vm.share_folder "yum", "/var/cache/yum", yum, :owner => "root", :group => "root"
  end
end

def setup_master(config)
  setup(config)
  vm_memory = ENV["MAESTRO_VM_MEMORY"] || 4096
  config.vm.customize ["modifyvm", :id, "--memory", vm_memory]

  # use local git repo
  config.vm.share_folder "puppet", "/etc/puppet", ".", :create => true, :owner => "puppet", :group => "puppet"

  commit = `git rev-parse HEAD`
  puts "Provisioning using commit #{commit} on branch #{ENV['BRANCH']}"
end

Vagrant::Config.run do |config|

  config.vm.box = ENV["MAESTRO_CENTOS_BOX"] || "CentOS-6.4-x86_64-minimal"
  config.vm.box_url = "https://repo.maestrodev.com/archiva/repository/public-releases/com/maestrodev/vagrant/CentOS/6.4/CentOS-6.4-x86_64-minimal.box"

  abort "MAESTRODEV_USERNAME must be set" unless ENV['MAESTRODEV_USERNAME']
  abort "MAESTRODEV_PASSWORD must be set" unless ENV['MAESTRODEV_PASSWORD']

  config.vm.define :default do |config|
    config.vm.network :hostonly, "192.168.33.30"
    config.vm.host_name = "maestro.acme.com"
    setup_master(config)
    config.vm.provision :shell do |shell|
      shell.path = "get-maestro.sh"
      shell.args = "#{ENV['MAESTRODEV_USERNAME']} #{ENV['MAESTRODEV_PASSWORD']} '#{ENV['NODE_TYPE']}' #{ENV['BRANCH']}"
    end
  end
  if ENV['MAESTRO_SLAVE']
    config.vm.define :slave do |config|
      config.vm.network :hostonly, "192.168.33.31"
      config.vm.host_name = "maestro-slave.acme.com"
      setup_master(config)
      config.vm.provision :shell do |shell|
        shell.path = "get-maestro.sh"
        shell.args = "#{ENV['MAESTRODEV_USERNAME']} #{ENV['MAESTRODEV_PASSWORD']} '#{ENV['NODE_TYPE']}' #{ENV['BRANCH']}"
      end
    end
  end
  config.vm.define :agent do |config|
    config.vm.network :hostonly, "192.168.33.40"
    config.vm.host_name = "maestro-agent-01.acme.com"
    setup(config)
    config.vm.provision :shell do |shell|
      shell.path = "get-agent.sh"
      shell.args = "maestro.acme.com 192.168.33.30"
    end
  end
end
