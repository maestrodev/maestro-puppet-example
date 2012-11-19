#!/bin/sh

# Script to install Maestro and all requirements in a CentOS 6.2+ server from scratch
# including Puppet master to easily start other nodes from it

USERNAME=$1
PASSWORD=$2


function install_gem {
  (gem list ^$1$ | grep $1) || gem install --no-rdoc --no-ri $1
  return $?
}
function gem_version {
  eval "$1=`cd /etc/puppet && bundle list $2 | sed -e "s/.*\/$2-\(.*\)/\1/"`"
}

# fail fast on any error
set -e

# Puppet repositories
cat > /etc/yum.repos.d/puppetlabs.repo <<EOF
[puppetlabs]
name=Puppetlabs
enabled=1
baseurl=http://yum.puppetlabs.com/el/6/products/\$basearch
gpgkey=http://yum.puppetlabs.com/RPM-GPG-KEY-puppetlabs
gpgcheck=1
EOF
cat > /etc/yum.repos.d/epel.repo <<EOF
[epel]
name=epel
mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-6&arch=\$basearch
enabled=1
gpgcheck=0
EOF

# get the puppet configuration skeleton
echo "Getting puppet configuration from GitHub"
yum -y install git
if [ ! -d /etc/puppet/.git ]
  then
  git clone https://github.com/maestrodev/maestro-puppet-example.git /etc/puppet
else
  cd /etc/puppet && git pull
fi

echo "Installing gems"
yum -y install rubygems
install_gem bundler
bundle install --gemfile /etc/puppet/Gemfile --without build

# fetch Puppet modules with librarian puppet
echo "Fetching Puppet modules"
cd /etc/puppet && bundle exec librarian-puppet install --verbose


# Puppet install and configuration
MASTER=`hostname`
# install puppet with same version as gems, as they may conflict
gem_version PUPPET_VERSION puppet
gem_version FACTER_VERSION facter
echo "Installing Puppet $PUPPET_VERSION"
yum -y install puppet-server-$PUPPET_VERSION facter-$FACTER_VERSION
puppet apply -e "augeas { 'puppet': \
  changes => [ \
    \"set /files/etc/puppet/puppet.conf/agent/server $MASTER\", \
    \"set /files/etc/puppet/puppet.conf/agent/certname $MASTER\", \
    \"set /files/etc/puppet/puppet.conf/master/autosign true\", \
  ], \
  incl => '/etc/puppet/puppet.conf', \
  lens => 'Puppet.lns', \
}"

# hiera configuration override
mkdir -p /etc/puppet/hieradata
cat > /etc/puppet/hieradata/common.yaml <<EOF
---
# MaestroDev credentials
maestro::repository::username: '$USERNAME'
maestro::repository::password: '$PASSWORD'
EOF

# create nodes
cat > /etc/puppet/manifests/nodes/$MASTER.pp << EOF
node "$MASTER" inherits "master_with_agent" {}
EOF

# enable puppet master
puppet resource service puppetmaster ensure=running enable=true
service puppetmaster start

# run puppet agent
echo "Running Puppet agent"
puppet agent --test
