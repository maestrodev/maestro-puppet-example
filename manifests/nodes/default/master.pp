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
  include maestro_nodes::nginx::jenkinsservernginx

  # Archiva
  include maestro_nodes::nginx::archivaservernginx

  # Maestro demo compositions
  include maestro_demo

}
