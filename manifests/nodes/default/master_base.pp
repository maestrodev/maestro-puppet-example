# A Maestro Master node with
#
# required services:
# * Maestro
# * ActiveMQ

node 'master_base' inherits 'parent' {

  include maestro_nodes::repositories

  # Maestro
  include maestro_nodes::nginx::maestroservernginx

}
