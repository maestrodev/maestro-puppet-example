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

  include maestro::repository
  include maestro_nodes::repositories

  # Maestro
  include maestro_nodes::maestroserver
  include maestro_nodes::nginxproxy

  # Jenkins
  include maestro_nodes::jenkinsserver
  include maestro_nodes::nginx::jenkins

  # Archiva
  include maestro::repository
  include maestro_nodes::archivaserver
  include maestro_nodes::nginx::archiva

  # Maestro demo compositions
  include maestro_demo

}
