#!/bin/sh

# Script to install Maestro and all requirements in a CentOS 6.2+ server from scratch
# including Puppet master to easily start other nodes from it

USERNAME=$1
PASSWORD=$2
NODE_TYPE=$3
ENVIRONMENT=$4

PUPPET_VERSION=3.4.2
FACTER_VERSION=1.7.4
PUPPETLABS_RELEASE_VERSION=6-10


if [ -z "$NODE_TYPE" ]; then
  NODE_TYPE=master_with_agent
fi

if [ -z "$ENVIRONMENT" ]; then
  ENVIRONMENT=production
fi

# fail fast on any error
set -e

# Puppet repositories
PUPPETLABS_RELEASE_URL=http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-$PUPPETLABS_RELEASE_VERSION.noarch.rpm
if ! rpm -q puppetlabs-release > /dev/null; then
  rpm -i $PUPPETLABS_RELEASE_URL
else
  rpm -q puppetlabs-release-$PUPPETLABS_RELEASE_VERSION > /dev/null || rpm -U $PUPPETLABS_RELEASE_URL
fi

# disable yum priorities, or fails to install puppet in Amazon AMI
if [ -e /etc/yum/pluginconf.d/priorities.conf ]
  then
  cat > /etc/yum/pluginconf.d/priorities.conf <<EOF
[main]
enabled = 0
EOF
fi

# Puppet install and configuration
MASTER=`hostname -f`
if [ -z "$MAESTRO_ENABLED" ]; then
  MAESTRO_ENABLED=true
fi

# install puppet

echo "Installing Puppet $PUPPET_VERSION"
yum -y install puppet-server-$PUPPET_VERSION facter-$FACTER_VERSION

if [ -z `facter fqdn` ]; then
  echo "Unable to find fact 'fqdn', please check your networking configuration"
  exit 1
fi

# install puppet config
if [ $ENVIRONMENT == "development" ]; then
  echo ************************************************************
  echo ************************************************************
  echo DEVELOPMENT MODE: Not installing Puppet modules RPM
  echo ************************************************************
  echo ************************************************************
else
  rpm -q maestro-puppet-example || yum install -y --enablerepo=maestrodev maestro-puppet-example
fi


cat << EOS | puppet apply --detailed-exitcodes || [ $? -eq 2 ]
  augeas { 'puppet':
    context => '/files/etc/puppet/puppet.conf',
    changes => [
      'set master/autosign true',
    ],
    incl => '/etc/puppet/puppet.conf',
    lens => 'Puppet.lns',
  }

  host { 'puppet':
    ensure => present,
    ip     => '127.0.0.1',
  }
EOS

# hiera configuration override
mkdir -p /etc/puppet/hieradata
# don't overwrite common.yaml if already exists
if [ ! -e /etc/puppet/hieradata/common.yaml ]
  then
  cat > /etc/puppet/hieradata/common.yaml <<EOF
---
# MaestroDev credentials
maestro::params::repo:
  url: 'https://repo.maestrodev.com/archiva/repository/all'
  username: '$USERNAME'
  password: '$PASSWORD'

maestro::yumrepo::username: '$USERNAME'
maestro::yumrepo::password: '$PASSWORD'

# Whether to start Maestro now or not (useful for creating images)
maestro::params::enabled: $MAESTRO_ENABLED
EOF
fi

# Create external facts
mkdir -p /etc/facter/facts.d
if [ ! -e /etc/facter/facts.d/maestro_node_type.txt ]
  then
  echo "maestro_node_type=$NODE_TYPE" > /etc/facter/facts.d/maestro_node_type.txt
fi
if [ ! -e /etc/facter/facts.d/maestro_host.txt ]
  then
  echo "maestro_host=localhost" > /etc/facter/facts.d/maestro_host.txt
fi


# create node if it doesn't exist already
if [ ! -e /etc/puppet/manifests/nodes/$MASTER.pp ]
  then
  cat > /etc/puppet/manifests/nodes/$MASTER.pp << EOF
node "$MASTER" inherits "$NODE_TYPE" {
  include maestro_nodes::firewall::maestro
  include maestro_nodes::firewall::puppetmaster
}
EOF
fi

# enable puppet master and disable puppet agent periodic runs
puppet resource Service puppetmaster ensure=running enable=true
puppet resource Service puppet ensure=stopped enable=false
service puppetmaster start

# run puppet agent
if [ "$NO_PROVISION" ]; then
  echo "Skipping provisioning"
  exit 0
fi

if [ "$DAEMON" == "true" ]; then
  echo "Running Puppet agent as a daemon"
  puppet agent --verbose --ignorecache --no-usecacheonfailure --no-splay --show_diff
else
  echo "Running Puppet agent"
  set +e
  puppet agent --test
  RETVAL=$?

  # Check Puppet return code to fail fast, using --detailed-exitcodes
  # If not using --detailed-exitcodes Puppet returns 0 even if there are failures
  case $RETVAL in

  2)  echo "Puppet Changes"
      ;;
  4)  echo "Puppet Failures" && exit $RETVAL
      ;;
  6)  echo "Puppet Changes and Failures" && exit $RETVAL
      ;;
  *) echo "Unknown Puppet exit code: $RETVAL" && exit $RETVAL
     ;;
  esac

fi
