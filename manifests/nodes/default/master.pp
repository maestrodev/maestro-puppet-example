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
  include maestro_nodes::nginx::maestroservernginx

  # Jenkins
  include maestro_nodes::nginx::jenkinsservernginx

  # Archiva
  include maestro_nodes::nginx::archivaservernginx

  # Maestro demo compositions
  include maestro_demo

}
