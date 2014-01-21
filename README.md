maestro-puppet-example
===================

Scripts and Puppet manifests to easily install Maestro and related services (jenkins, archiva,...) from scratch

Nodes defined
=============
There are a few useful nodes defined for a Maestro master server, agent node and maestro master+agent node. See the `manifests/nodes/default` files for details.
Includes classes defined in [Maestro-Nodes](https://github.com/maestrodev/puppet-maestro_nodes) for reusability.

Installing in a fresh machine
=============================
The script `get-maestro.sh` can install a Puppet master with all the required Maestro Puppet configuration and trigger a Puppet update to install Maestro and a Maestro agent from a minimal CentOS 6.3 server.

From a minimal CentOS 6.3 server you can run the script to automatically install everything, passing your MaestroDev provided username and password.

```
curl -L http://raw.github.com/maestrodev/maestro-puppet-example/master/get-maestro.sh | bash -s USERNAME PASSWORD
```

The puppet process can also be run in the background by setting the environment variable DAEMON to true.

```
curl -L http://raw.github.com/maestrodev/maestro-puppet-example/master/get-maestro.sh | DAEMON=true bash -s USERNAME PASSWORD
```

### Other parameters

The `get-maestro.sh` script accepts the following parameters in order

* username
* password
* node type [`master`, `master_with_agent`, or any of the other puppet nodes defined under `manifests/nodes/default`]
* environment [`development`] If set to `development` the rpm won't be installed, useful for Vagrant environments


### Setting up a Maestro server without any of the other servers (Maestro Agent, Jenkins, Archiva, etc)

You can install the Maestro server without any of the servers needed by the default examples. To do this, simply specify
the master_base node type when invoking the get-maestro.sh script. Like so:

```
curl -L http://raw.github.com/maestrodev/maestro-puppet-example/master/get-maestro.sh | bash -s USERNAME PASSWORD master_base
```

### Setting up a Puppet Master only

You can ask the `get-maestro.sh` to skip the Puppet step at the end. This
will set up a Puppet master on the machine, which can then be customised and
used for setting up other machines.

```
curl -L http://raw.github.com/maestrodev/maestro-puppet-example/master/get-maestro.sh | sudo NO_PROVISION=true bash -s USERNAME PASSWORD
```

### Creating an Image

To create an image of the Maestro master, it is best not to start the Maestro
software as it will configure itself for the current host. In this case, set
`MAESTRO_ENABLED` to `false`.

```
curl -L http://raw.github.com/maestrodev/maestro-puppet-example/master/get-maestro.sh | MAESTRO_ENABLED=false bash -s USERNAME PASSWORD
```

To later re-enable Maestro, edit the value in Hiera (see Customizing below).

Installing agents on CentOS with Puppet
=======================================
The script `get-agent.sh` can install a Puppet agent and trigger a Puppet update to install a Maestro agent from a minimal CentOS 6.3 server, installing typical tools like git, subversion, ruby, java,...

From a minimal CentOS 6.3 server you can automatically install the Maestro Agent, passing the hostname of the Maestro master server.
Optionally you can pass the ip of the master server too if there is no dns entry for the master hostname and it will create an entry in the agent /etc/hosts file to properly resolve the name to that ip.

```
curl -L http://raw.github.com/maestrodev/maestro-puppet-example/master/get-agent.sh | bash -s MASTER_HOSTNAME [MASTER_IP]
```

### Installing the agents on a machine with non-standard hostname.

By default, agent hosts must have the word *agent* in their name. If you want to install the agent on a machine that
doesn't have a host name that has the word *agent* in it, you must first add a node definition on the puppet master for
this new machine.  From the puppet master do the following:

``` cd /etc/puppet ```

```./add-agent-node.sh AGENTHOSTNAME```

Where *AGENTHOSTNAME* is the name of the host where you wish to install the agent.

Then, simply follow standard agent installation instructions on the agent host.

Upgrading
=========
## Maestro Master

You can run the `get-maestro.sh` to install all prerequisites (ie. Puppet and modules upgrades) in the master, but skipping the Puppet step at the end

    curl -L http://raw.github.com/maestrodev/maestro-puppet-example/master/get-maestro.sh | sudo NO_PROVISION=true bash -s USERNAME PASSWORD


Then puppet can be run as usual with the `--noop` flag to check that all changes look correct before applying them.
Note that some steps are expected to fail as they depend on file downloads that don't actually happen in noop mode. In case of doubts please use your [Maestro support account to contact us](https://support.maestrodev.com/).

    puppet agent --test --noop

If all looks correct Puppet can be run again to aply the changes

    puppet agent --test

## Maestro Agents

Agents can be updated the same way. First with `NO_PROVISION` to update the prerequisites if necessary, then running Puppet. We recommend updating one agent and check that it shows up in the Infrastructure tab in the Maestro Web UI before upgrading the rest of the agents.

    curl -L http://raw.github.com/maestrodev/maestro-puppet-example/master/get-agent.sh | sudo NO_PROVISION=true bash -s MASTER_HOSTNAME [MASTER_IP]
    sudo puppet agent --test --noop

If all looks good

    sudo puppet agent --test


Troubleshooting
===============

### Issues with hostnames

You might receive the following error:

```Unable to find fact 'fqdn', please check your networking configuration```

This should be corrected by ensuring that `hostname` and `hostname -d` have
the expected values. This will usually involve adjusting
`/etc/sysconfig/network` on CentOS (and either rebooting or changing
temporarily with `hostname` as well). You may also need to change
`/etc/resolv.conf` and/or `/etc/hosts`.

Problems can also be encountered if the hostname or domain name includes
uppercase characters. Use lowercase for more predictable results.

Customizing
===========
You can customize the installation using Puppet 3 Hiera's capabilities. The default configuration variables are in `/etc/puppet/hieradata/default.yaml`, and can be customized in `/etc/puppet/hieradata/common.yaml` for all nodes or `/etc/puppet/hieradata/$clientcert.yaml` for node specific configuration as defined in `hiera.yaml`.

You can add your own Puppet nodes to `/etc/puppet/manifests/nodes` and they will take precedence over those defined in `/etc/puppet/manifests/nodes/default` and will not be overwritten on upgrades.

Building
========
This project uses librarian-puppet to fetch all the required puppet modules as defined in Puppetfile, bundler for the gem dependencies defined in Gemfile, and rspec-puppet for unit tests.

To build everything and run the specs

```
bundle install
bundle exec rake
```

To just fetch the required puppet modules

```
bundle exec librarian-puppet install
```

Vagrant
-------
There are several Vagrant boxes defined:

* default: provisions using the modules checkout out in the local repo
* maestro: provisions using the script and modules from rpm as it would do in a real server
* agent: provisions an agent from another Puppet server, configured by default to 192.168.33.30

