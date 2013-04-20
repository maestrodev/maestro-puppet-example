# A Maestro Master node with
#
# required services:
# * Maestro
# * ActiveMQ
#
# services included but not required:
# * Jenkins
# * Archiva

node 'master' inherits 'master_base' {

  # Jenkins
  class { 'maestro_nodes::jenkinsserver': }
  include maestro_nodes::nginx::jenkins

  # Archiva
  class { 'maestro_nodes::archivaserver': }
  include maestro_nodes::nginx::archiva

  # open the firewall to the services: archiva, jenkins
  firewall { '100 allow jenkins and archiva':
    proto       => 'tcp',
    port        => [
      $archiva::port,
      $jenkins::jenkins_port,
    ],
    action      => 'accept',
  }

}
