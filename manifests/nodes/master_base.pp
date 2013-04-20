# A Maestro Master node with
#
# required services:
# * Maestro
# * ActiveMQ

node 'master_base' inherits 'parent' {

  class { 'maestro::repository': }

  include maestro

  include maestro_nodes::repositories

  include maestro_nodes::metrics_repo

  # Maestro master server
  class { 'maestro::maestro':
    repo => $maestro::repository::maestrodev,
    enabled => hiera('maestro::maestro::enabled'),
  }

  include maestro_nodes::database

  include maestro_nodes::nginxproxy

  # ActiveMQ
  class { 'activemq': }
  class { 'activemq::stomp': }

  # Maestro plugins
  class { 'maestro::plugins': }

  include maestro_nodes::maestrofirewall
  include maestro_nodes::firewall::puppetmaster
}
