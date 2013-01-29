#!/bin/sh

# Script to install Maestro and all requirements in a CentOS 6.2+ server from scratch
# including Puppet master to easily start other nodes from it

USERNAME=$1
PASSWORD=$2
BRANCH=demo

function install_gem {
  (gem list ^$1$ | grep $1) || gem install --no-rdoc --no-ri $1 -v $2
  return $?
}
function gem_version {
  eval "$1=`cat /etc/puppet/Gemfile.lock | grep "^[ ]\+$2 (" | head -n 1 | sed -e 's/.*(\(.*\))/\1/'`"
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

# Gem repositories
cat > /etc/gemrc <<EOF
:sources:
 - https://rubygems.org
 - https://gems.gemfury.com/19mFQpkpgWC8xqPZVizB/
EOF


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

gem_version LIBRARIAN_VERSION librarian-puppet-maestrodev
echo "Installing librarian-puppet-maestrodev $LIBRARIAN_VERSION"
yum -y install rubygems rubygem-json
install_gem librarian-puppet-maestrodev $LIBRARIAN_VERSION

# fetch Puppet modules with librarian puppet
echo "Fetching Puppet modules"
cd /etc/puppet && librarian-puppet install --verbose
# java module has bad permissions
for f in `find /etc/puppet/modules/java/ -type f `; do  chmod 644 $f; done

# Puppet install and configuration
MASTER=`hostname`
if [ -z "$MAESTRO_ENABLED" ]; then
  MAESTRO_ENABLED=true
fi
# install puppet with the version locked in gemfile
gem_version PUPPET_VERSION puppet
gem_version FACTER_VERSION facter
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
maestro::lucee::demo_compositions::archiva_host: '$MASTER'
maestro::lucee::demo_compositions::jenkins_host: '$MASTER'
maestro::lucee::demo_compositions::sonar_host: '$MASTER'
EOF

# create nodes
cat > /etc/puppet/manifests/nodes/$MASTER.pp << EOF
node "$MASTER" inherits "master_with_agent" {}
EOF

# enable puppet master and disable puppet agent periodic runs
puppet resource service puppetmaster ensure=running enable=true
puppet resource service puppet ensure=stopped enable=false
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
