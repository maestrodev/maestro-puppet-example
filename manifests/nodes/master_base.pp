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

  # Maestro demo compositions
  class { 'maestro::lucee::demo_compositions': }

  # Maestro master server
  class { 'maestro::maestro':
    repo => $maestro::repository::maestrodev,
    enabled => hiera('maestro::maestro::enabled'),
  }

  class { 'maestro_nodes::database': }

  # ActiveMQ
  class { 'activemq': }
  class { 'activemq::stomp': }

  # Maestro plugins
  class { 'maestro::plugins': }

  # open the firewall to the services: maestro, activemq, puppet CA
  firewall { '100 allow maestro':
    proto       => 'tcp',
    port        => [
      $maestro::maestro::port,
      $activemq::stomp::port,
      8140
    ],
    action      => 'accept',
  }

}
