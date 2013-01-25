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

  # Reporting

  include maestro_nodes::metrics_repo

  package { 'postfix':
    ensure => installed,
  } ->
  service {'postfix': 
    ensure => running,
  }
  package { 'maestro_reports':
    ensure => installed,
    provider=> gem,
  } ->
  cron { 'maestroreports':
    command => '/usr/bin/maestroreports',
    user    => 'maestro',
    hour    => 0,
    minute  => 0,
  }

  include maestro

  include maestro_nodes::repositories

  # Maestro demo compositions
  class { 'maestro::lucee::demo_compositions': }

  # Maestro master server
  class { 'maestro::maestro':
    repo => $maestro::repository::maestrodev,
    metrics_enabled    => true,    
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
