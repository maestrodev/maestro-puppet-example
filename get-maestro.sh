#!/bin/sh

# Script to install Maestro and all requirements in a CentOS 6.2+ server from scratch
# including Puppet master to easily start other nodes from it

USERNAME=$1
PASSWORD=$2
NODE_TYPE=$3
BRANCH=$4

if [ -z "$NODE_TYPE" ]; then
  NODE_TYPE=master_with_agent
fi

if [ -z "$BRANCH" ]; then
  BRANCH=master
fi

echo "get-maestro: Using branch $BRANCH"

function install_gem {
  (gem list ^$1$ | grep $1 | grep $2) || gem install --no-rdoc --no-ri $1 -v $2
  return $?
}
function gem_version {
  eval "$1=`cat /etc/puppet/Gemfile.lock | grep "^[ ]\+$2 (" | head -n 1 | sed -e 's/.*(\(.*\))/\1/'`"
}

# fail fast on any error
set -e

# Puppet repositories
rpm -q puppetlabs-release-6-7.noarch || \
  rpm -i http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm

# get the puppet configuration skeleton
echo "Getting puppet configuration from GitHub"
yum -y install git
if [ ! -d /etc/puppet/.git ]
  then
  rm -rf /etc/puppet
  git clone https://github.com/maestrodev/maestro-puppet-example.git /etc/puppet
  cd /etc/puppet && git checkout $BRANCH
else
  cd /etc/puppet && git pull && git checkout $BRANCH
fi

echo "Installing librarian-puppet-maestrodev $LIBRARIAN_VERSION"
yum -y install rubygems rubygem-json
# install puppet with the version locked in gemfile. Installing before
# librarian-puppet ensures we get the correct version here and in yum
gem_version FACTER_VERSION facter
install_gem facter $FACTER_VERSION
gem_version PUPPET_VERSION puppet
install_gem puppet $PUPPET_VERSION
gem_version LIBRARIAN_VERSION librarian-puppet-maestrodev
install_gem librarian-puppet-maestrodev $LIBRARIAN_VERSION

if [ -z `facter fqdn` ]; then
  echo "Unable to find fact 'fqdn', please check your networking configuration"
  exit 1
fi

# fetch Puppet modules with librarian puppet
echo "Fetching Puppet modules"
cd /etc/puppet && librarian-puppet install --verbose

# Puppet install and configuration
MASTER=`hostname`
if [ -z "$MAESTRO_ENABLED" ]; then
  MAESTRO_ENABLED=true
fi
echo "Installing Puppet $PUPPET_VERSION"
yum -y install puppet-server-$PUPPET_VERSION facter-$FACTER_VERSION
puppet apply -e "augeas { 'puppet':
  context => '/files/etc/puppet/puppet.conf',
  changes => [
    \"set agent/server $MASTER\",
    \"set agent/certname $MASTER\",
    \"set agent/pluginsync true\",
    \"set master/autosign true\",
  ],
  incl => '/etc/puppet/puppet.conf',
  lens => 'Puppet.lns',
}"

# hiera configuration override
mkdir -p /etc/puppet/hieradata
# don't overwrite common.yaml if already exists
if [ ! -e /etc/puppet/hieradata/common.yaml ]
  then
  cat > /etc/puppet/hieradata/common.yaml <<EOF
---
# MaestroDev credentials
maestro::repository::username: '$USERNAME'
maestro::repository::password: '$PASSWORD'

# Whether to start Maestro now or not (useful for creating images)
maestro::maestro::enabled: $MAESTRO_ENABLED

# Maestro Agent configuration
maestro::agent::stomp_host: '$MASTER'

# Archiva repository
maestro_nodes::repositories::host: '$MASTER'

# Demo compositions configuration
maestro_demo::archiva_host: '$MASTER'
maestro_demo::jenkins_host: '$MASTER'
maestro_demo::sonar_host: '$MASTER'

classes:
 - maestro_nodes::maestrofirewall
EOF
fi

# create nodes
cat > /etc/puppet/manifests/nodes/$MASTER.pp << EOF
node "$MASTER" inherits "$NODE_TYPE" {}
EOF

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
