maestro-puppet-example
===================

Scripts and Puppet manifests to easily install Maestro and related services (jenkins, archiva,...) from scratch

Nodes defined
=============
There are a few useful nodes defined for a Maestro master server, agent node and maestro master+agent node. See the `manifests/nodes` files for details.
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


Customizing
===========
You can customize the installation using Puppet 3 Hiera's capabilities. The default configuration variables are in `/etc/puppet/hieradata/default.yaml`, and can be customized in `/etc/puppet/hieradata/common.yaml` for all nodes or `/etc/puppet/hieradata/$clientcert.yaml` for node specific configuration as defined in `hiera.yaml`.

You can add your own Puppet nodes to `/etc/puppet/manifests/nodes`.

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

