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
  include maestro_nodes::jenkinsserver
  include maestro_nodes::nginx::jenkins

  # Archiva
  include maestro_nodes::archivaserver
  include maestro_nodes::nginx::archiva
}
