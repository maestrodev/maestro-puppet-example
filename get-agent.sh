#!/bin/sh

# Script to install a Maestro Agent and all requirements in a CentOS 6.2+ server from scratch
# MASTER_HOSTNAME needs to match the Puppet master certificate
# if called with MASTER_IP a new host entry is created in the agent to avoid the need of dns
# Syntax: get-agent.sh MASTER_HOSTNAME [MASTER_IP]

MASTER_HOSTNAME=$1
MASTER_IP=$2

function gem_version {
  eval "$1=`curl -s https://raw.github.com/maestrodev/maestro-puppet-example/master/Gemfile.lock | grep "^[ ]\+$2 (" | head -n 1 | sed -e 's/.*(\(.*\))/\1/'`"
}

# fail fast on any error
set -e

# Puppet repositories
# TODO installs 2 versions if previous already exists
rpm -q puppetlabs-release-6-7 || \
  rpm -i http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm

# Puppet install and configuration
gem_version PUPPET_VERSION puppet
echo "Installing Puppet agent $PUPPET_VERSION"
yum -y install puppet-$PUPPET_VERSION


# point to puppet master
if [ "$MASTER_IP" ]; then
  puppet apply -e "host { \"$MASTER_HOSTNAME\": \
    ip    => \"$MASTER_IP\", \
    alias => 'puppet' \
  }"
fi
puppet apply -e "augeas { 'puppet':
  context => '/files/etc/puppet/puppet.conf',
  changes => [
    \"set agent/server $MASTER_HOSTNAME\",
  ],
  incl => '/etc/puppet/puppet.conf',
  lens => 'Puppet.lns',
}"


# disable puppet agent polling
puppet resource service puppet ensure=stopped enable=false

# run puppet agent
if [ "$NO_PROVISION" ]; then
  echo "Skipping provisioning"
  exit 0
fi

if [ "$DAEMON" == "true" ]; then
  echo "Running Puppet agent as a daemon"
  puppet agent --verbose --ignorecache --no-usecacheonfailure --no-splay --show_diff --waitforcert 60
else
  echo "Running Puppet agent"
  set +e
  puppet agent --test --waitforcert 60
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
