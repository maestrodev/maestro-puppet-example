# Common config for all vms
def setup(config)
  # Keep downloaded packages in host for faster creation of new vms
  unless (ENV["MAESTRO_CACHE"] || "").empty?
    src = File.expand_path("~/.maestro/src")
    File.exists?(File.expand_path(src)) or Dir.mkdir(src)
    config.vm.synced_folder src, "/usr/local/src", :owner => "root", :group => "root"
    config.vm.synced_folder File.expand_path("~/.m2/repository"), "/var/local/maestro-agent/.m2/repository", mount_options_arwx
    config.vm.synced_folder File.expand_path("~/.m2/repository"), "/var/lib/jenkins/.m2/repository", mount_options_arwx
    # keep yum cache in host
    config.vm.provision :shell, :inline => "sed -i 's/keepcache=0/keepcache=1/' /etc/yum.conf"
    yum = File.expand_path("~/.maestro/yum")
    File.exists?(File.expand_path(yum)) or Dir.mkdir(yum)
    config.vm.synced_folder yum, "/var/cache/yum", :owner => "root", :group => "root"
  end
end

def setup_master(config)
  setup(config)
  vm_memory = ENV["MAESTRO_VM_MEMORY"] || 4096

  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", vm_memory]
  end
end

def mount_options_arwx
  Vagrant::VERSION =~ /1\.2\..*/ ? {:extra => "dmode=777,fmode=666"} : {:mount_options => ["dmode=777","fmode=666"]}
end

# Vagrant::Config.run do |config|
Vagrant.configure("2") do |config|

  config.vm.box = ENV["MAESTRO_CENTOS_BOX"] || "opscode-centos-6.5"
  config.vm.box_url = "http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box"

  abort "MAESTRODEV_USERNAME must be set" unless ENV['MAESTRODEV_USERNAME']
  abort "MAESTRODEV_PASSWORD must be set" unless ENV['MAESTRODEV_PASSWORD']

  # use local git repo for provisioning
  config.vm.define :default do |config|
    config.vm.hostname = "maestro-development.acme.com"
    config.vm.network :private_network, ip: "192.168.33.30"
    setup_master(config)

    config.vm.synced_folder ".", "/etc/puppet", mount_options_arwx

    config.vm.provision :shell do |shell|
      shell.path = "get-maestro.sh"
      shell.args = "#{ENV['MAESTRODEV_USERNAME']} #{ENV['MAESTRODEV_PASSWORD']} '#{ENV['NODE_TYPE']}' development"
    end
  end

  # use get-maestro script for provisioning
  config.vm.define :maestro do |config|
    config.vm.hostname = "maestro.acme.com"
    config.vm.network :private_network, ip: "192.168.33.20"
    setup_master(config)
    config.vm.provision :shell do |shell|
      shell.path = "get-maestro.sh"
      shell.args = "#{ENV['MAESTRODEV_USERNAME']} #{ENV['MAESTRODEV_PASSWORD']} '#{ENV['NODE_TYPE']}'"
    end
  end

  config.vm.define :slave do |config|
    config.vm.hostname = "maestro-slave.acme.com"
    config.vm.network :private_network, ip: "192.168.33.50"
    setup_master(config)
    config.vm.provision :shell do |shell|
      shell.path = "get-maestro.sh"
      shell.args = "#{ENV['MAESTRODEV_USERNAME']} #{ENV['MAESTRODEV_PASSWORD']} '#{ENV['NODE_TYPE']}'"
    end
  end
  config.vm.define :agent do |config|
    config.vm.hostname = "maestro-agent-01.acme.com"
    config.vm.network :private_network, ip: "192.168.33.40"
    setup(config)
    config.vm.provision :shell do |shell|
      shell.path = "get-agent.sh"
      shell.args = "maestro.acme.com 192.168.33.30"
    end
  end

  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"
    aws.name = "maestro-puppet-example-#{ENV['USER']}"
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    aws.keypair_name = ENV['USER']
    # CentOS 6 from https://aws.amazon.com/marketplace/pp/B00A6KUVBW
    # For some images you need to manually comment out the sudoers "Defaults requiretty" line with visudo
    aws.ami = "ami-eb6b0182"
    aws.instance_type = "m1.medium"
    aws.region = "us-east-1"
    aws.security_groups = ["maestro-master"]
    aws.tags = {"vagrant" => true, "user" => ENV['USER']}
    override.ssh.username = "root"
    override.ssh.private_key_path = File.expand_path("~/.ssh/id_rsa")
  end

  config.vm.provider :rackspace do |rs, override|
    override.vm.box = "dummy"
    rs.username = ENV['RACKSPACE_USERNAME']
    rs.api_key  = ENV['RACKSPACE_API_KEY']
    rs.flavor   = /4GB/
    rs.image    = /CentOS 6.4 with Puppet/
    rs.rackspace_region = :ord
    rs.public_key_path = File.expand_path("~/.ssh/id_rsa.pub")
    rs.server_name = "maestro-puppet-example-#{ENV['USER']}"
    override.ssh.username = "root"
    override.ssh.private_key_path = File.expand_path("~/.ssh/id_rsa")
  end
end
