#!/bin/sh

# Script to install a Maestro Agent and all requirements in a CentOS 6.2+ server from scratch
# MASTER_HOSTNAME needs to match the Puppet master certificate
# if called with MASTER_IP a new host entry is created in the agent to avoid the need of dns
# Syntax: get-agent.sh MASTER_HOSTNAME [MASTER_IP]

MASTER_HOSTNAME=$1
MASTER_IP=$2
ENVIRONMENT=$3

PUPPET_VERSION=3.4.2
FACTER_VERSION=1.7.4
PUPPETLABS_RELEASE_VERSION=6-10

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

# Puppet install and configuration
echo "Installing Puppet agent $PUPPET_VERSION"
yum -y install puppet-$PUPPET_VERSION


# point to puppet master
if [ "$MASTER_IP" ]; then
  cat << EOS | puppet apply --detailed-exitcodes || [ $? -eq 2 ]
    host { "$MASTER_HOSTNAME":
      ip    => "$MASTER_IP",
      alias => 'puppet'
    }
EOS
fi
cat << EOS | puppet apply --detailed-exitcodes || [ $? -eq 2 ]
augeas { 'puppet':
  context => '/files/etc/puppet/puppet.conf',
  changes => [
    "set agent/server $MASTER_HOSTNAME",
    "set agent/environment $ENVIRONMENT",
  ],
  incl => '/etc/puppet/puppet.conf',
  lens => 'Puppet.lns',
}
EOS

# Create external facts
mkdir -p /etc/facter/facts.d
if [ ! -e /etc/facter/facts.d/maestro_node_type.txt ]
  then
  echo "maestro_node_type=agent" > /etc/facter/facts.d/maestro_node_type.txt
fi
if [ ! -e /etc/facter/facts.d/maestro_host.txt ]
  then
  echo "maestro_host=$MASTER_HOSTNAME" > /etc/facter/facts.d/maestro_host.txt
fi

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
