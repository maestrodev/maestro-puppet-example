# A Maestro Master node with
#
# required services:
# * Maestro
# * ActiveMQ
#
# services included but not required:
# * Jenkins
# * Archiva

node 'master' inherits 'parent' {

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

  # Jenkins
  class { 'maestro_nodes::jenkinsserver': }

  # Archiva
  class { 'maestro_nodes::archivaserver': }

  # open the firewall to the services: maestro, archiva, jenkins, activemq, puppet CA
  firewall { '100 allow maestro':
    proto       => 'tcp',
    port        => [
      $maestro::maestro::port,
      $archiva::port,
      $jenkins::jenkins_port,
      $activemq::stomp::port,
      8140
    ],
    action      => 'accept',
  }

}
